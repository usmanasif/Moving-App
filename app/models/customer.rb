class Customer < ActiveRecord::Base
	belongs_to :creator, class_name: "User"
	# belongs_to :user
	has_and_belongs_to_many :users
	has_many :items
	attr_accessor :userid
end
