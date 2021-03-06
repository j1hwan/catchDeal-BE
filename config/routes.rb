Rails.application.routes.draw do
  root 'homes#index'

  ## 렌더 페이지
  get 'homes/index'

  # ------------------------------------ v 1.1 ---------------------------------------------
  ## 앱 기본통신 URI
  get 'hit_products/index' => 'hit_products#index'
  get 'hit-products/index' => 'hit_products#index'

  get 'hit_products/condition' => 'hit_products#condition'
  get 'hit-products/condition' => 'hit_products#condition'

  get 'hit_products/web_products_list' => "hit_products#web_products_list"
  get 'hit-products/web-products-list' => "hit_products#web_products_list"

  get 'hit_products/rank' => 'hit_products#rank'
  get 'hit-products/rank' => 'hit_products#rank'

  ## 통신 테스트
  get 'apis/test' => "apis/test"
  
  ## 푸쉬알람
  post 'send-pushalarm' => "apis#send_pushalarm"

  ## 북마크
  post 'book_mark_combine' => 'apis#bookmark_combine'
  post 'bookmark-combine' => 'apis#bookmark_combine'

  post 'book_mark_create' => 'apis#bookmark_create'
  post 'bookmark-create' => 'apis#bookmark_create'

  delete 'book_mark_destroy' => 'apis#bookmark_destroy'
  delete 'bookmark-destroy' => 'apis#bookmark_destroy'

  get 'book_mark_list' => 'apis#bookmark_list'
  get 'bookmark-list' => 'apis#bookmark_list'
  
  get 'bookmark-product-list' => 'apis#bookmark_product_list'
  
  ## 키워드 알람
  patch 'keyword-config' => 'apis#keyword_config'
  get 'keyword-user-status' => 'apis#keyword_user_status'
  post 'keyword-combine' => 'apis#keyword_combine'
  post 'keyword-create' => 'apis#keyword_create'
  delete 'keyword-destroy' => 'apis#keyword_destroy'
  get 'keyword-pushalarm-list' => 'apis#keyword_pushalarm_list'
  
  ## 공지사항
  resources :notices
  get '/notice.json' => 'notices#index_json'
  # ------------------------------------ v 1.1 ---------------------------------------------
  
  
  
  # ------------------------------------ v 2.0 ---------------------------------------------
  # [API 설계] https://collectiveidea.com/blog/archives/2013/06/13/building-awesome-rails-apis-part-1
  
  namespace :api, :path => "" do
    namespace :v2, :path => "" do
      resources :keyword_pushalarms, :only => [:index, :create, :destroy], path: "keyword-pushalarms"
      resource :keyword_pushalarms, :except => [:index, :show, :new, :create, :edit, :update], path: "keyword-pushalarms" do
        post 'send-pushalarm' => 'keyword_pushalarms#send_pushalarm'
        patch 'user-config' => 'keyword_pushalarms#user_config'
        get 'user-status' => 'keyword_pushalarms#status'
        post 'combine' => 'keyword_pushalarms#combine'
      end
      
      resources :bookmarks, :only => [:index]
      resource :bookmarks, :only => [:create, :destroy] do
        post 'combine' => 'bookmarks#combine'
      end
      resources :notices, :only => [:index]
      
      resource :authentication, :only => [], :path => "" do
        post 'auth-user' => 'authentication#authenticate_user'
        get 'auth-user' => 'authentication#auth_test'
      end
      
      resources :hit_products, :only => [:index], :path => "hit-products"
      resource :hit_products, :only => [], :path => "hit-products" do
        get 'search' => 'hit_products#search'
        get 'platform' => 'hit_products#platform'
        get 'rank' => 'hit_products#rank'
      end
    end
  end
  # ------------------------------------ v 2.0 ---------------------------------------------

  devise_for :users

  authenticate :user, lambda { |u| u.admin? } do
    begin
      get '/welcome' => 'homes#index'
      mount RailsAdmin::Engine => '/popstar/admin', as: 'rails_admin'
    rescue
      redirect_to new_user_session_path
    end
  end
end
