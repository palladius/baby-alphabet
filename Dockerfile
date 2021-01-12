#Dockerfile.rails
# From: https://docs.docker.com/compose/rails/#define-the-project

# TODO ricc ocnisder slimming it down as Julias says: https://medium.com/@yuliaoletskaya/how-to-start-your-rails-app-in-a-docker-container-9f9ce29ff6d6
#FROM ruby:2.6.5-slim-stretch     # Original Julia
#FROM ruby:2.7                    # Original Riccardo 
FROM ruby:2.7-slim     





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
RUN bundle install --jobs 5
# apt-get install sqlite3 libsqlite3-dev
COPY . /myapp

# runs on port 8080
CMD ["make", "run"]