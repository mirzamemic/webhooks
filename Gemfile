source "https://rubygems.org"

ruby "3.3.6"

gem "bcrypt"
gem "importmap-rails"
gem "kamal", require: false
gem "mission_control-jobs"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.1"
gem "stimulus-rails"
gem "stripe"
gem "thruster", require: false
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "bootsnap", require: false
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "dotenv"
  gem "factory_bot_rails"
  gem "faker"
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", require: false
  gem "rspec-rails"
  gem "sqlite3", ">= 2.1"
end

group :development do
  gem "web-console"
end

group :production do
  gem "pg"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 6.0"
end
