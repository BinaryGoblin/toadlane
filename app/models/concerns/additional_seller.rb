module AdditionalSeller

	extend ActiveSupport::Concern
	
	included do 
	  attr_accessor :additional_seller_ids, :group_name, :value, :role

		has_many :users, through: :group_sellers
  	has_many :group_sellers

  	def additional_sellers
  		users
  	end
	end

  def add_additional_sellers(user)
    unless additional_sellers.include?(user)
      additional_sellers << user
    end
  end
end