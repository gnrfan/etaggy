require 'rubygems'
require 'sinatra'

Sinatra::Application.set(
    :run            => false,
    :environment    => :production,
    :app_file       => 'application.rb'
)

require 'application'
run Sinatra::Application
