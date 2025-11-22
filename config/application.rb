require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Zztomatozz
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.i18n.available_locales = [ :en, :zh ]
    config.i18n.default_locale = :zh
    config.i18n.fallbacks = [ :en ]

    config.session_store :cookie_store,
      key: "_zztomatozz_session",
      expire_after: 6.months,
      secure: Rails.env.production?,
      httponly: true,
      same_site: :lax
  end
end
