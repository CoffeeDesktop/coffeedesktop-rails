# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
DesktopjsRails::Application.initialize!

require 'pusher' 
Pusher.app_id = '34812' 
Pusher.key = 'c69a5b636526c8cde52a' 
Pusher.secret = '7f7042941b4086df7288'

