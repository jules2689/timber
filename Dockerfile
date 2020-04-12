FROM ruby:2.6.6 as source

ENV RAILS_ENV production
WORKDIR /app

# Specify non-root user
RUN apt-get update && apt-get install sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
USER docker
RUN sudo chown -R docker:docker /app

# Install JDK
RUN sudo apt-get install -y default-jdk
RUN java --version
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

# Node & Yarn
RUN curl https://deb.nodesource.com/setup_12.x | sudo bash
RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN sudo apt-get update && sudo apt-get install -y nodejs yarn

# Install Elasticsearch
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-6.x.list
RUN sudo apt-get update && sudo apt-get install -y elasticsearch

# Copy Dependency Definitions
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY package.json /app/package.json
COPY yarn.lock /app/yarn.lock

# Install Dependencies
RUN gem install bundler
RUN bundle config --local build.sassc --disable-march-tune-native
RUN bundle config set deployment 'true'
RUN bundle config set without 'development test'
ENV BUNDLE_BUILD__SASSC=--disable-march-tune-native
RUN bundle install
RUN yarn install

# Copy over App, Config, & Generate Assets
COPY . /app
RUN sudo rm -rf /app/tmp/*

# Fix Elasticsearch
RUN sudo chown -R docker:docker /etc/default/elasticsearch
RUN sudo chown -R docker:docker /etc/elasticsearch
RUN sudo chown -R docker:docker /var/log/elasticsearch
RUN sudo chown -R docker:docker /var/lib/elasticsearch

# Make sure we own /app and compile assets
ARG secret_key_base=06a4324b503986b092979b00398
ENV SECRET_KEY_BASE=$secret_key_base
RUN sudo chown -R docker:docker /app
RUN bin/rails assets:precompile

# Run the app
ADD bin/entrypoint.sh /app/bin/entrypoint.sh
RUN sudo chmod +x /app/bin/entrypoint.sh
ENV FULL_LOGGING 1
ENV RAILS_SERVE_STATIC_FILES 1
ENV SETUP_ES 1
EXPOSE 3000
ENTRYPOINT ["/app/bin/entrypoint.sh"]
