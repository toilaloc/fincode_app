# Multi-stage build for optimized production image
# Stage 1: Build dependencies
FROM ruby:3.2-slim AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  mariadb-client \
  default-libmysqlclient-dev \
  libyaml-dev \
  git \
  curl \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Stage 2: Production image
FROM ruby:3.2-slim

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
  mariadb-client \
  default-libmysqlclient-dev \
  libyaml-dev \
  curl \
  tzdata \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy gems from builder
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy and set permissions for entrypoint first
COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p log tmp/pids tmp/sockets tmp/cache storage

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3000/api/v1/health || exit 1

EXPOSE 3000

ENTRYPOINT ["/bin/bash", "/app/docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

