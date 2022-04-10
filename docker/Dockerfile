FROM ruby:3.0.2
ENV LANG C.UTF-8

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs

RUN gem install bundler -v 2.0.2

# ルートディレクトリを作成
RUN mkdir -p /usr/app

# 作業ディレクトリを指定
WORKDIR /usr/app

# ローカルのGemfileとGemfile.lockをコピー
COPY Gemfile /usr/app/Gemfile
COPY Gemfile.lock /usr/app/Gemfile.lock
RUN bundle install

WORKDIR /eater
COPY . /eater