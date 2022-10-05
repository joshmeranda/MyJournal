FROM ubuntu:22.10

# all the tools needeed to run every tool to be tested
#RUN apk update \
#    && apk add cmake coreutils jq make tar xz \
#       gcc ncurses
RUN apt-get update \
      && apt-get upgrade --assume-yes \
      && apt-get --assume-yes install wget build-essential cmake ncurses-dev libncurses5-dev libpcre2-dev gettext jq

# we just need to keep the container running indefinitely (basically a busy box)
CMD sleep inf