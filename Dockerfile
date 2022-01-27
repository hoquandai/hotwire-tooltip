#=== Start from a small trusted base image
FROM ruby:3.1-alpine AS base

# Install system dependencies required both at run time and build time.
RUN apk add --update --no-cache tzdata sqlite-dev bash gcompat

#=== This stage will be responsible for installing gems
FROM base AS dependencies

RUN apk add --update --no-cache build-base

COPY Gemfile Gemfile.lock ./

RUN bundle install --jobs=3 --retry=3

#=== Back to base stage
FROM base
# Set the base directory that will be used from now on
ENV RAILS_ROOT /app
RUN mkdir $RAILS_ROOT
WORKDIR $RAILS_ROOT

# Create a dedicated user for running the application
RUN adduser -D app-user

# Set the user for RUN, CMD or ENTRYPOINT calls from now on
# Note that this doesn't apply to COPY or ADD, which use a --chown argument instead
USER app-user

# Copy over gems from the dependencies stage
COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/

# Finally, copy over the code
# This is where the .dockerignore file comes into play
# Note that we have to use `--chown` here
COPY --chown=app-user . ./

EXPOSE 3000 80

ENTRYPOINT ["bundle", "exec"]

CMD ["rails", "server", "-b", "0.0.0.0"]
