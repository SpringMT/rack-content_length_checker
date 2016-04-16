require 'bundler'
Bundler.setup(:default, :test)
Bundler.require(:default, :test)

require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start

$TESTING=true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rack/content_length_checker'
