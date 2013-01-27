# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
CoffeeDesktopRails::Application.initialize!

require 'pusher' 
Pusher.app_id = ENV['PUSHER_APPID']
Pusher.key = ENV['PUSHER_KEY'] 
Pusher.secret = ENV['PUSHER_SECRET']

