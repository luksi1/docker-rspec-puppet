FROM ubuntu:16.04
MAINTAINER luksi1

ARG puppetversion

# Set working dir as variable
ENV MODULE_DIR /module

RUN apt update && \
    apt install -y ruby-full build-essential zlib1g-dev libaugeas-dev pkg-config

# Add Gemfile
ADD Gemfile /

RUN gem install net-telnet -v '0.1.1'
RUN gem install bundler
RUN PUPPET_GEM_VERSION=${puppetversion} bundle install --clean --force --system --gemfile /Gemfile

# Setup a directory to load a module for test
VOLUME ${MODULE_DIR}

# Define our working dir
WORKDIR ${MODULE_DIR}

# Our default command
CMD rm -rf Gemfile.lock && \
    bundle exec rake spec_clean && \
    bundle exec rake spec

# Atomic Metadata
LABEL RUN="docker run -it --rm -v \$(pwd):/module:z -v IMAGE"
