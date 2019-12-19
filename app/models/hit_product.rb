class HitProduct < ApplicationRecord
    attr_accessor :dateAgo, :shortDate, :uid, :isSoldOut, :imageUrl, :isDeleted, :shortUrl
    validates_uniqueness_of :url, :scope => :title
	
	has_many :book_marks
    has_many :app_users, through: :book_marks
end
