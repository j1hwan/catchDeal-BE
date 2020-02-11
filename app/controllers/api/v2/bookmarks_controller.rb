class Api::V2::BookmarksController < Api::V2::BaseController
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  include HitProductsHelper
  before_action :jwt_authenticate_request!
  
    def combine
        begin
            json_params = JSON.parse(request.body.read)
            product = HitProduct.find_by(product_id: json_params["product"]["id"])
            
            if product.nil?
                render json: { errors: ['유효하지 않는 product_id'] }, status: :unauthorized
            
            elsif product != nil	  
                @bookMark = BookMark.find_by(app_user_id: @currentAppUser.id, hit_product_id: product.id)
            
                if @bookMark.nil?
                    @bookMarkResult = BookMark.create(app_user_id: @currentAppUser.id, hit_product_id: product.id)
                    @dataJson = { :message => "북마크가 생성되었습니다.",
                                    :bookMark => {
                                    :userId => @currentAppUser.id,
                                    :hitProductTitle => BookMark.eager_load(:hit_product).find(@bookMarkResult.id).hit_product.title
                                    }
                                }
                
                render :json => @dataJson, :except => [:id, :created_at, :updated_at]
                else
                    @bookMark.destroy
                    render :json => { :message => "북마크가 삭제되었습니다." }
                end
            end
        rescue
            render json: {errors: ['Invalid Body']}, :status => :bad_request
        end
    end
    
    def index
        sql = "
  		    SELECT DISTINCT *, CASE WHEN book_marks IS NULL THEN false ELSE true END AS is_bookmark FROM hit_products
				LEFT JOIN book_marks ON book_marks.hit_product_id = hit_products.id
			WHERE book_marks.app_user_id = #{@currentAppUser.id}
			ORDER BY date DESC;
      	"
      	@productData = ActiveRecord::Base.connection.execute(sql)
      	
      	arr = Array.new
      	
      	orderStack = 1
      	@productData.each do |data|
      		arr.push([orderStack, data["keyword_title"], data["product_id"], data["title"], data["view"], data["comment"], data["like"], data["score"], "#{time_ago_in_words(data["date"])} 전", data["image_url"], data["is_sold_out"], data["dead_check"], data["is_title_changed"], data["url"], data["redirect_url"], data["is_bookmark"]])
      		orderStack += 1
      	end
      	
      	@result = keyword_pushalarm_list_data_push(arr, @currentAppUser.id)
      	render :json => { :userId => @currentAppUser.id, :pushList => @result }
    end
    
    def create
        json_params = JSON.parse(request.body.read)
        product = HitProduct.find_by(product_id: json_params["product"]["id"])
    
        if product.nil?
            render json: { errors: ['유효하지 않는 product_id'] }, :status => :bad_request
        
        elsif product != nil	  
            @bookMark = BookMark.find_by(app_user_id: @currentAppUser.id, hit_product_id: product.id)
        
            if @bookMark.nil?
                @bookMarkResult = BookMark.create(app_user_id: @currentAppUser.id, hit_product_id: product.id)
                @dataJson = { :message => "북마크가 생성되었습니다.",
                            :bookMark => { :userId => @currentAppUser.id,
                                            :hitProductTitle => BookMark.eager_load(:hit_product).find(@bookMarkResult.id).hit_product.title
                                        }
                            }
                
                render :json => @dataJson, :except => [:id, :created_at, :updated_at]
            else
                render json: { errors: ['이미 북마크가 존재합니다.'] }, status: :forbidden
            end
        end
    end
    
    def destroy
        json_params = JSON.parse(request.body.read)
        product = HitProduct.find_by(product_id: json_params["product"]["id"])
    
        if product.nil?
            render json: { errors: ['유효하지 않는 product_id'] }, :status => :bad_request
        
        elsif product != nil
            @bookMark = BookMark.find_by(app_user_id: @currentAppUser.id, hit_product_id: product.id)
        
            if @bookMark != nil
                @bookMark.destroy
                render :json => { :message => "북마크가 삭제되었습니다." }
            elsif @bookMark.nil?
                render json: { errors: ['북마크가 존재하지 않습니다.'] }, status: :forbidden
            end
        end
    end
end