require 'rubygems'
require 'bundler'

Bundler.require(:default)
require "./tender_endpoint"

run TenderEndpoint
