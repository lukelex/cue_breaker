# frozen_string_literal: true

require "rubygems"

require "cue_breaker"

require "rspec"
require "pry-nav"

RSpec.configure do |config|
  config.disable_monkey_patching!

  def cue_sheet_fixture(cuename)
    File.read(File.join(File.dirname(__FILE__), "fixtures/#{cuename}.cue"))
  end
end
