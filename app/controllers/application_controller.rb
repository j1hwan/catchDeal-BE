class ApplicationController < ActionController::Base
    skip_before_action :verify_authenticity_token
    include Pagy::Backend
	
	attr_reader :app_user

	protected
	
	def jwt_authenticate_request!
		
		begin
			JWT.decode(request.headers['Authorization'], ENV["SECRET_KEY_BASE"])
			unless user_id_in_token?
				render json: { errors: ['Not Authenticated'] }, status: :unauthorized
				return
			end
		rescue JWT::ExpiredSignature
			render json: { errors: ['Token Expired'] }, status: :unauthorized
			return
		end
		
		begin
			@current_user = AppUser.find(auth_token[:app_user_id])
		rescue
			render json: { errors: ['Invalid token'] }, status: :unauthorized
		end
		
		rescue JWT::VerificationError, JWT::DecodeError
		render json: { errors: ['Not Authenticated'] }, status: :unauthorized
	end

	private
	def http_token
		@http_token ||= if request.headers['Authorization'].present?
			request.headers['Authorization']
		end
	end

	def auth_token
		@auth_token ||= JsonWebToken.decode(http_token)
	end

	def user_id_in_token?
		http_token && auth_token && auth_token[:user_id].to_i
	end
end
