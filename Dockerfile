FROM ruby:3.1-alpine

RUN apk add --update --no-cache bash build-base tzdata sqlite-dev gcompat

# Set the base directory that will be used from now on
ENV RAILS_ROOT /app
RUN mkdir $RAILS_ROOT
WORKDIR $RAILS_ROOT

# Create a dedicated user for running the application
RUN adduser -D app-user

# Set the user for RUN, CMD or ENTRYPOINT calls from now on
# Note that this doesn't apply to COPY or ADD, which use a --chown argument instead
USER app-user

# The files will be owned by app-user
COPY --chown=app-user Gemfile Gemfile.lock ./

RUN bundle install --jobs=3 --retry=3

COPY --chown=app-user . ./

EXPOSE 3000 80

ENTRYPOINT ["bundle", "exec"]

CMD ["rails", "server", "-b", "0.0.0.0"]
