package com.actionml.harness.integrationtest

import io.circe.parser._
import zio._
import zio.stream.{ZSink, ZStream}

import scala.util.Try

object CompareResults extends App {
  override def run(args: List[String]): ZIO[Any, Nothing, Int] = {
    def parseResults(s: String): Map[String, Double] =
      (parse(s) match {
        case Right(r) =>
          (r \\ "result").head.asArray.get.toList
            .map(j => ((j \\ "item").head.asString.get, (j \\ "score").head.asNumber.get.toDouble))
        case Left(_) => Nil
      }).toMap
    def fn(percentage: Float) = {
      val threshold = percentage / 100
      val in = System.in
      ZStream.fromInputStream(in, 512).mapErrorCause(_ => Cause.empty)
        .chunks
        .transduce(ZSink.utf8DecodeChunk)
        .transduce(ZSink.splitLines)
        .flatMap(c => ZStream.fromChunk(c))
        .filter { line =>
          val s = line.trim
          s.nonEmpty && (s.startsWith("<") || s.startsWith(">"))
        }
        .fold((List.empty[String], List.empty[String])) { (acc, i) =>
          if (i.startsWith("<")) (i.drop(1) :: acc._1, acc._2)
          else (acc._1, i.drop(1) :: acc._2)
        }
        .filterOrDieMessage { case (a, b) => a.size == b.size } ("Size of expected and actual lists should be the same")
        .map { case (a, b) =>
          (a zip b).filterNot { case (actual, expected) =>
            val aFields = parseResults(actual)
            val eFields = parseResults(expected)
            (aFields.keys != eFields.keys && (aFields.values.forall(_ != 0) || eFields.values.forall(_ != 0))) ||
              (aFields.keys == eFields.keys && {
                aFields.zip(eFields).forall { case ((_, aVal), (_, eVal)) =>
                  val max = Math.max(aVal, eVal)
                  Math.abs(aVal - eVal) / (if (max == 0) 1 else max) <= threshold
                }
              })
          }.foreach { case (a, e) =>
            println(s"<$a")
            println(s">$e")
          }
        }.as(1)
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

