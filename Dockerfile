FROM 286523409430.dkr.ecr.eu-west-3.amazonaws.com/base:v1 AS base

# install default version of bundler & install default version of passenger #gem update --system && \
RUN gem install bundler --version 2.0.1 && \
  gem install passenger --version 6.0.2 


FROM base AS dependencies

COPY Gemfile Gemfile.lock  ./

# install application dependencies
RUN bundle install -j64
RUN passenger-config compile-agent --auto --optimize && \
  passenger-config install-standalone-runtime --auto --url-root=fake --connect-timeout=1 && \
  passenger-config build-native-support
  
 
FROM base
# create a user for running the application  
RUN adduser -D my-app-user
USER my-app-user

# source code 
WORKDIR /srv/code
# copy dependencies from dependencies to final step
COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/

COPY --chown=my-app-user . /srv/code

EXPOSE 9393
# cleaning the previous precompiled assets & precompile assets before pushing code to production
RUN rm -rf /srv/code/public/assets && rake assets:precompile

ENTRYPOINT bundle exec passenger start --port 3000 --log-level 3 --min-instances 5 --max-pool-size 5 
