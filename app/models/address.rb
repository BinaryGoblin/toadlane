# == Schema Information
#
# Table name: addresses
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string
#  line1      :string
#  line2      :string
#  zip        :string
#  city       :string
#  state      :string
#  country    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Address < ActiveRecord::Base
  belongs_to :user
  has_many :stripe_orders
  has_many :green_orders

  validates_presence_of :name, :line1, :city, :state, :zip, :country

  def get_inline_address
    if line2.nil?
      " " + name + ", " + line1 + ", " + city + ", " + state + " " + zip + ", " + country
    else
      " " + name + ", " + line1 + " " + line2 + ", " + city + ", " + state + " " + zip + ", " + country
    end
  end
end
