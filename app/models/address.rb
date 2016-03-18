class Address < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :name, :line1, :city, :state, :zip, :country
  
  def get_inline_address
    if line2.nil?
      :name + ", " + :line1 + ", " + :city + ", " + :state + " " + :zip + ", " + :country
    else
      :name + ", " + :line1 + " " + :line2 + ", " + :city + ", " + :state + " " + :zip + ", " + :country
    end
  end
end