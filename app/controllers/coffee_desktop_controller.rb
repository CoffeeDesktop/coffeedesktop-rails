class CoffeeDesktopController < ApplicationController
	#before_filter :set_user

	def index

	end

	def apps
		@apps = [ 'sa', 'ircgatewayapp', 'pusher_chat', 'oa']
		render  :json => @apps
	end

	#Watch out lazy developer here
	#im so lazy that i will put api of pusher_chat here ... nobody can't stop me!

	def pch_post 
			data = {"nick" => params[:nick],"msg" => params[:msg], "date" =>Time.new.to_s}
			Pusher['pusher_chat'].trigger('data-changed',
			data.to_json) 
			render :text => data.to_json
	end



	# end of pusher_chat :D

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
