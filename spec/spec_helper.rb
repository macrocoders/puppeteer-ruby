require 'bundler/setup'
require 'puppeteer'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around(:each, type: :puppeteer) do |example|
    if example.metadata[:puppeteer].to_s == 'browser'
      Puppeteer.launch do |browser|
        @puppeteer_browser = browser
        example.run
      end
    else
      Puppeteer.launch do |browser|
        @puppeteer_page = browser.pages.first || browser.new_page
        example.run
      end
    end
  end

  config.define_derived_metadata(file_path: %r(/spec/integration/)) do |metadata|
    metadata[:type] = :puppeteer
  end

  module PuppeteerMethods
    def browser
      @puppeteer_browser or raise NoMethodError.new('undefined method "browser" (If you intended to use puppeteer#browser, you have to add `puppeteer: :browser` to metadata.)')
    end

    def page
      @puppeteer_page or raise NoMethodError.new('undefined method "page"')
    end
  end
  config.include PuppeteerMethods, type: :puppeteer
end
