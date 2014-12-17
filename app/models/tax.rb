class Tax < ActiveRecord::Base
  belongs_to :product

  validates_presence_of :value
end
