FROM ruby:2.3
RUN apt-get update && \
    apt-get install -y cmake 
COPY wincrementor.rb ./wincrementor.rb
COPY Gemfile ./Gemfile
RUN bundle install
