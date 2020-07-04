# frozen_string_literal: true

Raven.configure do |config|
  config.dsn = "https://#{ENV['SENTRY_KEY']}:#{ENV['SENTRY_SECRET']}@sentry.io/#{ENV['SENTRY_PROJECT']}"
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.environments = %w[production]
  # config.environments = %w[development]
end
