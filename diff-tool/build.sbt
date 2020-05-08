import sbt._
import sbt.Keys.resolvers

lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.actionml",
      scalaVersion := "2.13.1",
      version      := "0.2.0-SNAPSHOT"
    )),
    addCompilerPlugin("org.typelevel" %% "kind-projector"     % "0.10.3"),
    addCompilerPlugin("com.olegpy"    %% "better-monadic-for" % "0.3.0"),
    name := "diff-tool",
    resolvers += "Sonatype OSS Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots",
    resolvers += "Sonatype OSS Releases" at "https://oss.sonatype.org/content/repositories/releases",
    libraryDependencies ++= Seq(
      "dev.zio" %% "zio"              % "1.0.0-RC18-2",
      "dev.zio" %% "zio-streams"      % "1.0.0-RC18-2",
      "io.circe" %% "circe-core"    % "0.12.3",
      "io.circe" %% "circe-parser"  % "0.12.3",
    )
  )
  .enablePlugins(JavaAppPackaging, GraalVMNativeImagePlugin)
