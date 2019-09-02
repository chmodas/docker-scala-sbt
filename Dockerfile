FROM openjdk:8u222-jdk-slim-buster

# Env variables
ARG SCALA_VERSION
ENV SCALA_VERSION ${SCALA_VERSION:-2.12.9}
ARG SBT_VERSION
ENV SBT_VERSION ${SBT_VERSION:-1.2.8}
ARG DOCKER_VERSION
ENV DOCKER_VERSION ${DOCKER_VERSION:-19.03.1}
ARG DOCKER_COMPOSE_VERSION
ENV DOCKER_COMPOSE_VERSION ${DOCKER_COMPOSE_VERSION:-1.24.1}

ENV SCALA_PATH /usr/local/share/${SCALA_VERSION}
ENV PATH "$PATH:$SCALA_PATH/bin"

# Install build stuff
RUN set -eux; \
      apt-get update; \
      apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl gnupg2 software-properties-common

# Install sbt
RUN set -eux; \
      echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list; \
      apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823; \
      apt-get update; \
      apt-get install -y --no-install-recommends sbt; \
      sbt about

# Install Scala
RUN set -eux; \
      curl -L https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfzv - -C /usr/local/share; \
      rm -f scala-$SCALA_VERSION.tgz

# Install Docker
RUN set -eux; \
      curl -L https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz | tar xfzv - --strip-components 1 --directory /usr/local/bin/; \
      dockerd --version; \
      docker --version

# Install Docker Compose
RUN set -eux; \
      curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose; \
      chmod +x /usr/bin/docker-compose; \
      docker-compose --version

# Clean up
RUN set -eux; \
      apt-get clean; \
      rm -f /usr/local/openjdk-8/src.zip

