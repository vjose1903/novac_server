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

RUN ln -fs /usr/share/zoneinfo/America/Santo_Domingo /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

ENV TZ="America/Santo_Domingo"


WORKDIR /usr/src/novac_server
COPY ["Gemfile", "Gemfile.lock", "/usr/src/novac_server/"]
RUN gem install rails
RUN gem install nokogiri --platform=ruby
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install
COPY [".", "/usr/src/novac_server/"]
RUN bundle lock --add-platform x86_64-linux
# RUN rails db:drop db:create db:migrate db:seed

EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0", "--port", "3000"]