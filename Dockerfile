FROM ruby:2.5
RUN ruby --version
RUN apt-get update && \
    apt-get install cmake -y
WORKDIR /tmp
RUN gem install docopt 
RUN gem install rugged

RUN git clone https://github.com/Praqma/PlusBump.git -b rebirth .
RUN gem build plusbump.gemspec
RUN gem install plusbump-2.0.pre.alpha.gem

RUN mkdir -p /repo
WORKDIR /repo
VOLUME /repo

ENTRYPOINT ["plusbump"]
CMD ["--help"]
