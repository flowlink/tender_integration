source 'https://www.rubygems.org'

gem 'endpoint_base', github: 'spree/endpoint_base'
gem 'tender-api'

group :test do
  gem 'vcr'
  gem 'rspec', '2.11.0'
  gem 'webmock', '1.11.0'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'rack-test'
end

group :production do
  gem 'foreman'
  gem 'unicorn'
end

gem 'pry', group: :development
