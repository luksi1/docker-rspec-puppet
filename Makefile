# Base the name of the software on the spec file
REPO = rspec-puppet

LATEST_VERSION := $(shell curl -s https://rubygems.org/gems/puppet/versions | grep https://rubygems.org/gems/puppet/versions/ | sed '/^\/ >/d' | sed 's/<[^>]*.//g' | xargs | sed -e 's/\s\s*/\n/g' | sort | uniq | tail -1)

ifneq ($(origin DOCKER_USER), undefined)
DOCKER_USER := ${DOCKER_USER}/
endif

# Since the targets puppet3 and puppet4 match directories
# we have to fool make
# https://stackoverflow.com/questions/3931741/why-does-make-think-the-target-is-up-to-date/3931814
.PHONY: all puppet3 puppet4 puppet5 latest

# Variables for clean build directory tree under repository
all: puppet3 puppet4 puppet5 latest

puppet3:
	docker build -t ${DOCKER_USER}${REPO}:puppet3 --build-arg puppetversion=3.8 .

puppet4:
	docker build -t ${DOCKER_USER}${REPO}:puppet4 --build-arg puppetversion=4.2 .

puppet5:
	docker build -t ${DOCKER_USER}${REPO}:puppet5 --build-arg puppetversion=5.5 .

latest:
	docker build -t ${DOCKER_USER}${REPO}:latest --build-arg puppetversion=${LATEST_VERSION} .

publish:
	docker push ${DOCKER_USER}${REPO}:puppet3
	docker push ${DOCKER_USER}${REPO}:puppet4
	docker push ${DOCKER_USER}${REPO}:puppet5
	docker push ${DOCKER_USER}${REPO}:latest
