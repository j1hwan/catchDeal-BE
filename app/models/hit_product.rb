class HitProduct < ApplicationRecord
    attr_accessor :productId, :dateAgo, :order, :isSoldOut, :imageUrl, :isDeleted, :shortUrl, :isTitleChanged
    validates_uniqueness_of :url, :scope => :title
	
	has_many :book_marks
    has_many :app_users, through: :book_marks
end
