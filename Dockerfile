
#FROM AWSACCOUNTID.dkr.ecr.us-east-1.amazonaws.com/base:v@BASE_NUMBER 
FROM nirh237/base:v1
# install default version of bundler & install default version of passenger
RUN gem install bundler --version 2.0.1 && \
  gem install passenger --version 6.0.2

# create a user for running the application
RUN adduser -D my-app-user
USER my-app-user

WORKDIR /srv/code
COPY --chown=my-app-user Gemfile /srv/code
COPY --chown=my-app-user Gemfile.lock /srv/code


# install application dependencies
RUN bundle install -j64
RUN passenger-config compile-agent --auto --optimize && \
  passenger-config install-standalone-runtime --auto --url-root=fake --connect-timeout=1 && \
  passenger-config build-native-support
  
#

# source code
COPY --chown=my-app-user . /srv/code
RUN rm -rf /srv/code/public/assets && rake assets:precompile

EXPOSE 9393


ENTRYPOINT bundle exec passenger start --port 3000 --log-level 3 --min-instances 5 --max-pool-size 5 
