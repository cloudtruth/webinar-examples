FROM ruby:3.2.2-alpine

ENV APP_DIR="/srv/app" \
    BUNDLE_PATH="/srv/bundler" \
    APP_PACKAGES="build-base ruby-dev bash curl tzdata git less"
ENV BUNDLE_BIN="${BUNDLE_PATH}/bin" \
    BUNDLE_APP_CONFIG="${BUNDLE_PATH}" \
    GEM_HOME="${BUNDLE_PATH}"
ENV PATH="${APP_DIR}:${APP_DIR}/bin:${BUNDLE_BIN}:${PATH}"

RUN mkdir -p $APP_DIR $BUNDLE_PATH
WORKDIR $APP_DIR

RUN apk add --no-cache \
    --virtual app \
    $APP_PACKAGES

COPY Gemfile* $APP_DIR/
RUN bundle config --local without 'development test' && \
    bundle install --jobs=4

COPY . $APP_DIR/

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0"]
