# spec/support/vcr_setup.rb
require "vcr"
require "webmock/rspec"

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"  # Directory where VCR will store the request/response records
  config.hook_into :webmock  # Use WebMock to intercept HTTP requests
  config.configure_rspec_metadata!  # Allows VCR to be triggered by RSpec metadata

  # Ignore localhost, Rails logs, or any external services you don’t want VCR to record
  config.ignore_localhost = true
  config.ignore_hosts "127.0.0.1", "localhost"
end
