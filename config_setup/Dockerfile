FROM ruby:3.0.4

RUN apt-get update -qq && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -

RUN apt-get update -qq && apt-get install -y build-essential apt-utils postgresql-client git yarn tzdata graphviz libgmp3-dev libxslt-dev libxml2-dev pkg-config nano cron nodejs python3 python3-pip
RUN python3 -m pip install --no-cache-dir holidays

RUN ln -fs /usr/share/zoneinfo/America/Santo_Domingo /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

ENV TZ="America/Santo_Domingo"

WORKDIR /usr/src/novac_server
COPY ["Gemfile", "Gemfile.lock", "package.json", "package-lock.json", "/usr/src/novac_server/"]
RUN npm install
RUN gem install rails
RUN gem install nokogiri --platform=ruby
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install
RUN gem install bundler
RUN bundle update --bundler
COPY [".", "/usr/src/novac_server/"]
RUN bundle lock --add-platform x86_64-linux

RUN bundle exec wheneverize . &&\
    whenever --update-crontab &&\
    touch log/cron.log &&\
    chmod +rw log/cron.log &&\
		chmod +x /usr/src/novac_server/run_server.sh &&\
		chmod +x /usr/src/novac_server/wait-for-it.sh


CMD ["rails", "server", "-b", "0.0.0.0", "--port", "$$DB_PORT$$"]

