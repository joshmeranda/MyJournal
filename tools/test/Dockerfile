FROM ubuntu:22.10

# all the tools needeed to run every tool to be tested
RUN apt-get update \
      && apt-get upgrade --assume-yes \
      && apt-get --assume-yes install wget build-essential cmake ncurses-dev libncurses5-dev libpcre2-dev gettext curl jq

RUN wget https://github.com/mikefarah/yq/releases/download/v4.33.3/yq_linux_amd64 \
      && mv yq_linux_amd64 /usr/bin/yq \ 
      && chmod +x /usr/bin/yq

# we just need to keep the container running indefinitely (basically a busy box)
# todo: add shunit2 to container to run the given scripts
CMD sleep inf