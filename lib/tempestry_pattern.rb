require 'open-uri'
require 'nokogiri'
require 'pry'
require 'date'
require 'sqlite3'

require "tempestry_pattern/version"
require_relative './tempestry_pattern/color'
require_relative './tempestry_pattern/scraper'
require_relative './tempestry_pattern/weather'
require_relative './tempestry_pattern/cli'

module TempestryPattern
  class Error < StandardError; end
  # Your code goes here...
end
