# FROM ruby:3.0.4-alpine3.15

# COPY ["Gemfile", "Gemfile.lock", "/usr/src/novac_server/"]

# WORKDIR /usr/src/novac_server

# RUN apk add build-base postgresql-dev
# RUN gem install rails
# RUN bundle install

# COPY [".", "/usr/src/novac_server/"]

# CMD ["sh"]
# FROM  ubuntu:latest

FROM ruby:3.0

RUN apt-get update -qq && apt-get install -y build-essential postgresql-client git nodejs yarn tzdata graphviz libgmp3-dev libxslt-dev libxml2-dev pkg-config nano

WORKDIR /usr/src/novac_server
COPY ["Gemfile", "Gemfile.lock", "/usr/src/novac_server/"]
RUN gem install rails
RUN gem install nokogiri --platform=ruby
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install
COPY [".", "/usr/src/novac_server/"]
RUN bundle lock --add-platform x86_64-linux
# RUN /bin/rails db:environment:set RAILS_ENV=development
# Add a script to be executed every time the container starts.

EXPOSE 3000

# Configure the main process to run when running the image
# CMD ["rails", "server", "-b", "0.0.0.0"]
CMD ["/bin/sh"]