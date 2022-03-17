FROM AWSACCOUNTID.dkr.ecr.us-east-1.amazonaws.com/base:v@BASE_NUMBER
WORKDIR /srv/code
COPY . /srv/code


# install default version of bundler
RUN gem install bundler --version 2.0.1

# install default version of passenger
RUN gem install passenger --version 6.0.2

RUN bundle install -j64
RUN passenger-config compile-agent --auto --optimize && \
  passenger-config install-standalone-runtime --auto --url-root=fake --connect-timeout=1 && \
  passenger-config build-native-support

expose 9393

RUN rm -rf /srv/code/public/assets && rake assets:precompile
ENTRYPOINT bundle exec passenger start --port 3000 --log-level 3 --min-instances 5 --max-pool-size 5 