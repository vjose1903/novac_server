FROM ruby:3.0.4

ARG NODE_MAJOR=20

RUN apt-get update -qq && apt-get install -y --no-install-recommends curl ca-certificates gnupg && \
    curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential apt-utils postgresql-client git yarn tzdata graphviz libgmp3-dev libxslt-dev libxml2-dev pkg-config nano cron nodejs python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*
RUN python3 -m pip install --no-cache-dir holidays

RUN ln -fs /usr/share/zoneinfo/America/Santo_Domingo /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

ENV TZ="America/Santo_Domingo"
ENV PORT="$$DB_PORT$$"

WORKDIR /usr/src/novac_server
COPY ["Gemfile", "Gemfile.lock", "package.json", "package-lock.json", "/usr/src/novac_server/"]
RUN npm ci
RUN gem install bundler -v 2.5.23 && \
    bundle config set build.nokogiri --use-system-libraries && \
    bundle install
COPY [".", "/usr/src/novac_server/"]

RUN bundle exec wheneverize . &&\
    whenever --update-crontab &&\
    touch log/cron.log &&\
    chmod +rw log/cron.log &&\
		chmod +x /usr/src/novac_server/run_server.sh &&\
		chmod +x /usr/src/novac_server/wait-for-it.sh


CMD ["sh", "./run_server.sh"]

