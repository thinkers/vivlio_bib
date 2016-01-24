#!/bin/bash

if ! command -v gpg >/dev/null
then brew install gpg
fi

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3

if ! command -v curl >/dev/null
then brew install curl
fi

if ! command -v bash >/dev/null
then brew install bash
fi

curl -sSL https://get.rvm.io | bash -s stable

rvm install 2.1
rvm use 2.1 --default

gem install bundler

bundle install --full-index

