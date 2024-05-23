FROM ruby

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y ffmpeg

ADD Gemfile* *.gemspec ./

RUN bundle install

COPY . .
