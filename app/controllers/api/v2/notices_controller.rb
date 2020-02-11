class Api::V2::NoticesController < Api::V2::BaseController
    include ActionView::Helpers::DateHelper
    
    def index
        @notices = Notice.order("created_at DESC")
        
        @stackNumber = 1
        @notices.each do |currentData|
            currentData.uid = @stackNumber
            currentData.shortDate = currentData.created_at.strftime('%Y-%m-%d %H:%M:%S')
            currentData.dateAgo = "#{time_ago_in_words(currentData.created_at)} 전"
            @stackNumber += 1
        end
        
        render :json => @notices, :methods => [:uid, :shortDate, :dateAgo], :except => [:id, :user_id, :updated_at]
    end
end