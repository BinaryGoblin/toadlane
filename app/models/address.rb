class Address < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :name, :line1, :city, :state, :zip, :country
end