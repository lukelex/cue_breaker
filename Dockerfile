FROM ruby

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y ffmpeg

COPY . .

RUN bundle install

RUN gem build ./cue_breaker.gemspec
RUN gem install cue_breaker-*
