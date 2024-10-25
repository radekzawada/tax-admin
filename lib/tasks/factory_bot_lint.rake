namespace :factory_bot do
  desc "Lint factories"
  task lint: :environment do
    begin
      puts "Linting FactoryBot factories..."
      FactoryBot.lint(strategy: :build)
      puts "All factories are valid."
    rescue => e
      puts "FactoryBot linting failed!"
      puts e.message
      exit 1
    end
  end
end
