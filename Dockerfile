FROM chmodas/openjdk-docker-compose:11

# Env variables
ARG SCALA_VERSION
ARG SBT_VERSION

ENV SCALA_VERSION ${SCALA_VERSION:-2.13.1}
ENV SCALA_PATH /usr/share/scala
ENV SBT_VERSION ${SBT_VERSION:-1.3.9}
ENV SBT_PATH /usr/share/sbt
ENV PATH "$PATH:$SBT_PATH/bin:$SCALA_PATH/bin"

# Install sbt
RUN set -eux; \
  curl -L https://piccolo.link/sbt-$SBT_VERSION.tgz | tar xfzv - -C /usr/share; \
  rm -f $SBT_PATH/bin/*.bat

# Install Scala
RUN set -eux; \
  curl -L https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfzv - -C /usr/share; \
  mv /usr/share/scala-${SCALA_VERSION} $SCALA_PATH

# Prepare SBT
RUN set -eux; \
  sbt sbtVersion; \
  mkdir -p project; \
  echo "scalaVersion := \"${SCALA_VERSION}\"" > build.sbt; \
  echo "sbt.version=${SBT_VERSION}" > project/build.properties; \
  echo "case object Temp" > Temp.scala; \
  sbt compile; \
  rm -rf project target build.sbt Temp.scala

# Clean up
RUN set -eux; \
  apt-get clean

