# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string
#  resource_id   :integer
#  resource_type :string
#  created_at    :datetime
#  updated_at    :datetime
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  validates_presence_of :name
  validates_uniqueness_of :name

  scopify

  GROUP_ADMIN = 'group admin'
  PRIVATE_SELLER = 'private seller'
  PUBLIC_SELLER = 'public seller'
  PRIVATE_SUPPLIER = 'private supplier'
  PUBLIC_SUPPLIER = 'public supplier'
end
