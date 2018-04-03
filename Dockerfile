FROM ubuntu:16.04
MAINTAINER Luke Simmons

# Set working dir as variable
ENV module_dir /module
ENV UBUNTU_CODENAME xenial

RUN apt update && \
    apt install -y wget && \
    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb && \
    dpkg -i puppetlabs-release-pc1-xenial.deb

RUN apt update && \
    apt install -y pdk ruby-full build-essential zlib1g-dev libaugeas-dev augeas-dbg ruby-augeas augeas-tools

# Add Gemfile
ADD Gemfile /

# Configure to ever install a ruby gem docs then
# Install the relevant gems and cleanup after
#RUN printf "gem: --no-rdoc --no-ri" >> /etc/gemrc && \
#    gem install json -v '1.8.3' && \
#    gem install bundler

# Set Puppet Version
# TODO: Eventually we wont need separate files for this
# https://github.com/docker/docker/issues/14634
ENV puppetversion "~> 4.2"

# Now do the bundle install. I Split this off to minimize differences between 3 and 4
RUN gem install bundler
RUN PUPPET_GEM_VERSION=${puppetversion} bundle install --clean --system --gemfile /Gemfile

# Setup a directory to load a module for test
VOLUME ${module_dir}

# Define our working dir
WORKDIR ${module_dir}

# Our default command
CMD rm -rf Gemfile.lock && \
    bundle exec rake spec_clean && \
    bundle exec rake spec

# Atomic Metadata
LABEL RUN="docker run -it --rm -v \$(pwd):/module:z -v \${OPT1}:/ssh-agent:z -e SSH_AUTH_SOCK=/ssh-agent IMAGE"
