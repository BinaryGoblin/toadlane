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

  before_save :set_iso_state_for_us

  def get_inline_address
    if state.nil? && line2.nil?
      " " + name + ", " + line1 + ", " + city + ", " + " " + zip + ", " + country
    else
      if line2.nil?
        " " + name + ", " + line1 + ", " + city + ", " + state + " " + zip + ", " + country
      else
        " " + name + ", " + line1 + " " + line2 + ", " + city + ", " + state + " " + zip + ", " + country
      end
    end
  end

  def full_address
    [line1, line2].compact.reject(&:blank?).join(', ')
  end

  private

  def set_iso_state_for_us
    if country == 'US' && state.length > 2
      us_state = USStates::STATES.select { |st| st[:name].downcase == state.downcase }.first
      self.state = us_state[:abbreviation] if us_state.present?
    end
  end
end
