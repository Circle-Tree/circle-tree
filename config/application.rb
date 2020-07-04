# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AppName
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.i18n.default_locale = :ja
    config.active_job.queue_adapter = :sidekiq
    config.filter_parameters += [/password/]
    config.assets.enabled = false
    # field_with_errorsを作らせない
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.generators do |g|
      g.test_framework :rspec,
      view_specs: false,
      helper_specs: false,
      controller_specs: false,
      routing_specs: false
    end
  end
end
