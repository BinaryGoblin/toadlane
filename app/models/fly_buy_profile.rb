# == Schema Information
#
# Table name: fly_buy_profiles
#
#  id                    :integer          not null, primary key
#  synapse_user_id       :string
#  user_id               :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  encrypted_fingerprint :string
#  synapse_node_id       :string
#  synapse_ip_address    :string
#

class FlyBuyProfile < ActiveRecord::Base
  belongs_to :user

  attr_accessor :name_on_account, :account_num, :routing_num, :bank_name, :address, :eic_doc, :ssn_number, :date_of_company

  EscrowNodeID = '57d7465386c2732e824b7c8b'
  AppUserId = '57d745ff86c27319cbe0edf0'
  AppFingerPrint = '8781321799f523327fb8d1f15ffa266d'

end
