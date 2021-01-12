#Dockerfile.rails
# From: https://docs.docker.com/compose/rails/#define-the-project

FROM ruby:2.7
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

# runs on port 8080
CMD ["make", "run"]