require "i18n/backend/fallbacks"

I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
I18n::Backend::Simple.include(I18n::Backend::Metadata)

I18n.load_path += Dir[Rails.root.join("config/locales/**/*.yml")]
