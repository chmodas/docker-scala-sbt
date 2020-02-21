FROM chmodas/openjdk-docker-compose:11.0.6

# Env variables
ARG SCALA_VERSION
ARG SBT_VERSION

ENV SCALA_VERSION ${SCALA_VERSION:-2.12.9}
ENV SCALA_PATH /usr/share/scala-${SCALA_VERSION}
ENV SBT_VERSION ${SBT_VERSION:-1.2.8}
ENV SBT_PATH /usr/share/sbt-${SBT_VERSION}
ENV PATH "$PATH:$SBT_PATH/bin:$SCALA_PATH/bin"

# Install build stuff
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl gnupg2 software-properties-common

# Install sbt
RUN set -eux; \
  curl -L https://piccolo.link/sbt-$SBT_VERSION.tgz | tar xfzv - -C /usr/share; \
  mv /usr/share/sbt $SBT_PATH; \
  rm -f $SBT_PATH/bin/*.bat; \
  rm -rf sbt-$SCALA_VERSION.tgz

# Install Scala
RUN set -eux; \
  curl -L https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfzv - -C /usr/share; \
  rm -f scala-$SCALA_VERSION.tgz

# Prepare SBT
RUN set -eux; \
  sbt sbtVersion; \
  mkdir -p project; \
  echo "scalaVersion := \"${SCALA_VERSION}\"" > build.sbt; \
  echo "sbt.version=${SBT_VERSION}" > project/build.properties; \
  echo "case object Temp" > Temp.scalal; \
  sbt compile; \
  rm -rf project target build.sbt Temp.scala

# Clean up
RUN set -eux; \
  apt-get clean; \
  rm -f /usr/local/openjdk-8/src.zip

