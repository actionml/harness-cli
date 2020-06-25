package com.actionml.harness.integrationtest

import io.circe.parser._
import zio._
import zio.stream.{ZSink, ZStream}

import scala.util.Try

object CompareResults extends App {
  override def run(args: List[String]): ZIO[Any, Nothing, Int] = {
    def parseResults(s: String): List[(String, Double)] =
      parse(s) match {
        case Right(r) =>
          (r \\ "result").head.asArray.get.toList
            .map(j => ((j \\ "item").head.asString.get, (j \\ "score").head.asNumber.get.toDouble))
        case Left(_) => Nil
      }
    def fn(percentage: Float) = {
      val threshold = percentage / 100
      val in = System.in
      ZStream.fromInputStream(in, 512).mapErrorCause(_ => Cause.empty)
        .chunks
        .transduce(ZSink.utf8DecodeChunk)
        .transduce(ZSink.splitLines)
        .flatMap(c => ZStream.fromChunk(c))
        .filter(s => s.trim.nonEmpty && (s.contains("<") || s.contains(">")))
        .fold((List.empty[String], List.empty[String])) { (acc, i) =>
          if (i.startsWith("<")) (i.drop(1) :: acc._1, acc._2)
          else (acc._1, i.drop(1) :: acc._2)
        }
        .filterOrDieMessage { case (a, b) => a.length == b.length }("Size of expected and actual lists should be the same")
        .map { case (a, b) => a.map(i => i -> parseResults(i)) zip b.map(i => i -> parseResults(i)) }
        .map {
          _.zipWithIndex.foreach {
            case (((origa, a), (origb, b)), i) =>
              if (a.map(_._1).toSet != b.map(_._1).toSet) {
                println(s"<$origa")
                println(s">$origb")
              }
              (a zip b).foreach {
                case (x, y) =>
                  if (Math.abs(x._2 - y._2) / Math.min(x._2, y._2) > threshold) {
                    println(s"<$origa")
                    println(s">$origb")
                  }
              }
          }
        }
        .map(_ => 1)
    }

    args.headOption match {
      case Some(v) if Try(v.toFloat).isSuccess => fn(v.toFloat).onError(_ => IO.succeed(1))
      case None => fn(1).onError(_ => IO.succeed(1))
      case _ =>
        println("USAGE: compare-results <inaccuracy-in-measurements-as-percentage>\n" +
          "EXAMPLE (compare expected.file and actual.file from current dir, all keys should be the same, values should differ less then 2%:\n" +
          "diff actual.file expected.file | compare-results 2\n" +
          "This pipe outputs original diffs (if exist)")
        ZIO.succeed(1)
    }
  }
}

