namespace :factory_bot do
  desc "Lint factories"
  task lint: :environment do
    begin
      puts "Linting FactoryBot factories..."
      ENV["RAILS_ENV"] = "test"
      FactoryBot.lint
      puts "All factories are valid."
    rescue => e
      puts "FactoryBot linting failed!"
      puts e.message
      exit 1
    ensure
      puts "Cleaning up the database..."
      DatabaseCleaner.clean_with(:truncation)
    end
  end
end
