#Dockerfile.rails
# From: https://docs.docker.com/compose/rails/#define-the-project

# TODO ricc ocnisder slimming it down as Julias says: https://medium.com/@yuliaoletskaya/how-to-start-your-rails-app-in-a-docker-container-9f9ce29ff6d6
#FROM ruby:2.6.5-slim-stretch     # Original Julia
#FROM ruby:2.7                    # Original Riccardo 

# 2021-12-26:
#FROM ruby:2.7.5-slim     
FROM ruby:2.7.2 as development
# 2021-12-26 TODO(ricc): Se questo va Ric ristabilisci la versione SLIM
#FROM ruby:2.7.2





# libpq-dev for PostgreSQL.
RUN apt-get update -qq && apt-get install -y curl build-essential \
  && \
  curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y nodejs yarn

RUN apt-get install -y sqlite3 libsqlite3-dev
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
#sqlite bug 
# E brava Julia!
RUN bundle install --jobs 20 --retry 3
# apt-get install sqlite3 libsqlite3-dev
COPY . /myapp

# runs on port 8080
CMD ["make", "run"]