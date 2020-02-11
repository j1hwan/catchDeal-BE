class Api::V2::AuthenticationController < Api::V2::BaseController
    before_action :jwt_authenticate_request!, :only => [:auth_test]
    
    def auth_test
        @dataJson = { :message => "[Test] Token 인증 되었습니다! :D", :user => { :appPlayerId => @currentAppUser.id, :appPlayer => @currentAppUser.app_player, :lastTokenGetDate => @currentAppUser.last_token } }
        render :json => @dataJson, :except => [:id, :created_at, :updated_at, :category]
    end
	
    def authenticate_user
        begin
            json_params = JSON.parse(request.body.read)
            user = AppUser.find_or_create_by(app_player: json_params["auth"]["appPlayerId"])
            if user.nil?
                render json: {errors: ['Invalid Player Id']}, status: :unauthorized
            else
                user.update(last_token: Time.zone.now)
                render json: payload(user)
            end
        rescue
            render json: {errors: ['Invalid Player Id']}, status: :unauthorized
        end
    end

    private
    
    def payload(user)    
        @token = JWT.encode({ app_user_id: user.id, exp: 6.months.from_now.to_i }, ENV["SECRET_KEY_BASE"])
        # @token = JWT.encode({ app_user_id: user.id, exp: 1.minutes.from_now.to_i }, ENV["SECRET_KEY_BASE"])
        @tree = { "token" => @token } 
        
        return @tree
    end
end