FROM ruby:2.6.6

ENV RAILS_ENV production
COPY . /app
WORKDIR /app

# Java
RUN apt-get update && \
    apt-get install -y default-jdk && \
    apt-get clean;

# ElasticSearch
RUN apt install apt-transport-https
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN sh -c 'echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" > /etc/apt/sources.list.d/elastic-6.x.list'
RUN apt update
RUN apt install elasticsearch

# Node & Yarn
RUN curl https://deb.nodesource.com/setup_12.x | bash
RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y nodejs yarn

# Dependencies
RUN gem install bundler
RUN bundle config set deployment 'true'
RUN bundle install --without development test
RUN yarn install

EXPOSE 6778
ENTRYPOINT ./bin/entrypoint.sh
