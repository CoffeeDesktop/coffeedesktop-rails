class DesktopjsController < ApplicationController
	#before_filter :set_user

	def index

	end

	def apps
		@apps = ['sa', 'ircgatewayapp']
		render  :json => @apps
	end

	private

	def set_user
		if !user_signed_in?
			redirect_to '/users/sign_in'
		end
		if session[:user_id] != nil
			@user = User.find(session[:user_id])
		end
	end
end
