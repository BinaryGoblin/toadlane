# == Schema Information
#
# Table name: fly_buy_profiles
#
#  id                               :integer          not null, primary key
#  synapse_user_id                  :string
#  user_id                          :integer
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  encrypted_fingerprint            :string
#  synapse_node_id                  :string
#  synapse_ip_address               :string
#  eic_attachment_file_name         :string
#  eic_attachment_content_type      :string
#  eic_attachment_file_size         :integer
#  eic_attachment_updated_at        :datetime
#  bank_statement_file_name         :string
#  bank_statement_content_type      :string
#  bank_statement_file_size         :integer
#  bank_statement_updated_at        :datetime
#  gov_id_file_name                 :string
#  gov_id_content_type              :string
#  gov_id_file_size                 :integer
#  gov_id_updated_at                :datetime
#  permission_scope_verified        :boolean          default(FALSE)
#  kba_questions                    :json
#  terms_of_service                 :boolean          default(FALSE)
#  name_on_account                  :string
#  ssn_number                       :string
#  date_of_company                  :datetime
#  dob                              :datetime
#  entity_type                      :string
#  entity_scope                     :string
#  company_email                    :string
#  tin_number                       :string
#  completed                        :boolean          default(FALSE)
#  company_phone                    :string
#  error_details                    :json
#  unverify_by_admin                :boolean          default(FALSE)
#  business_documents_file_name     :string
#  business_documents_content_type  :string
#  business_documents_file_size     :integer
#  business_documents_updated_at    :datetime
#  additional_information           :string
#  outside_the_us                   :boolean          default(FALSE)
#  submited                         :boolean          default(FALSE)
#  bank_details_verified            :boolean          default(FALSE)
#  synapse_company_doc_id           :string
#  synapse_user_doc_id              :string
#  company_doc_verified             :boolean          default(FALSE)
#  user_doc_verified                :boolean          default(FALSE)
#  profile_type                     :string
#  gender                           :string
#

class FlyBuyProfile < ActiveRecord::Base
  belongs_to :user
  has_one :fly_buy_profile_notification, dependent: :destroy
  has_many :activities, class_name: 'Task', as: :taskable, dependent: :destroy

  attr_accessor :account_num, :routing_num, :bank_name, :address, :email, :question_1, :question_2, :question_3,
    :question_4, :question_5

  EscrowNodeID = Rails.env.development? ? Rails.application.secrets['SYNAPSEPAY_ESCROW_NODE_ID'] : ENV['SYNAPSEPAY_ESCROW_NODE_ID']
  AppUserId = Rails.env.development? ? Rails.application.secrets['SYNAPSEPAY_APP_USER_ID'] : ENV['SYNAPSEPAY_APP_USER_ID']
  AppFingerPrint = Rails.env.development? ? Rails.application.secrets['SYNAPSEPAY_APP_FINGERPRINT'] : ENV['SYNAPSEPAY_APP_FINGERPRINT']

  EscrowFeeHolderNodeId = Rails.env.development? ? Rails.application.secrets['SYNAPSEPAY_ESCROW_FEE_HOLDER_NODE_ID'] : ENV['SYNAPSEPAY_ESCROW_FEE_HOLDER_NODE_ID']

  has_attached_file :eic_attachment
  has_attached_file :bank_statement
  has_attached_file :gov_id
  has_attached_file :business_documents

  do_not_validate_attachment_file_type :eic_attachment
  do_not_validate_attachment_file_type :bank_statement
  do_not_validate_attachment_file_type :gov_id
  do_not_validate_attachment_file_type :business_documents

  scope :permission_verified, -> { where(permission_scope_verified: true) }

  def masked_tin_number
    masked_number(tin_number) if tin_number.present?
  end

  def masked_ssn_number
    masked_number(ssn_number) if ssn_number.present?
  end

  def profile_submited?
    submited? && error_details.blank? && !completed?
  end

  def tier
    profile_type.capitalize.gsub('_', ' ')
  end

  private

  def masked_number(number)
    "*****#{number}"
  end
end
