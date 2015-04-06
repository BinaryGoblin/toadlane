class User < ActiveRecord::Base
  rolify
  acts_as_messageable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :products

  has_many :requests_of_sender, class_name: 'Request', foreign_key: :sender_id
  has_many :requests_of_receiver, class_name: 'Request', foreign_key: :receiver_id

  has_one :certificate, dependent: :destroy
  has_one :armor_profile, dependent: :destroy

  has_and_belongs_to_many :roles,
                          :join_table => :users_roles,
                          :foreign_key => 'user_id',
                          :association_foreign_key => 'role_id'

  has_attached_file :asset, styles: {
                                small: '155x155#',
                                medium: '240x225#'
                              },
                              default_url: '/avatar/:style/missing.png'
  do_not_validate_attachment_file_type :asset

  before_destroy { roles.clear }

  serialize :benefits, Array

  scope :featured, -> { limit(16) }

  after_save :create_armor_profile,
    if: -> { self.name && self.phone },
    unless: -> { self.armor_profile }
  after_save :update_all_the_things,
    if: -> { self.armor_profile }

  def update_all_the_things
    # data = ArmorService.new
    # data.update_user({
    #    :account => current_user.armor_profile.armor_account,
    #   'user' => current_user.armor_profile.armor_user,
    #   'user_name' => current_user.name,
    #   'user_phone' => current_user.phone
    # })
    # data.update_company({
    #   :account => current_user.armor_profile.armor_account,
    #   'company' => current_user.company
    # })
    # data.update_address({
    #  :account => current_user.armor_profile.armor_account,
    #   'address' => current_user.address,
    #   'city' => current_user.city,
    #   'state' => current_user.state,
    #   'postal_code' => current_user.postal_code,
    #   'country' => current_user.country
    # })
    # data.create_armor_bank_account({
    #   :account => current_user.armor_profile.armor_account,
    #   'type' => current_user.armor_bank_account.account_type,
    #   'location' => current_user.armor_bank_account.account_location,
    #   'bank' => current_user.armor_bank_account.account_bank,
    #   'routing' => current_user.armor_bank_account.account_routing,
    #   'swift' => current_user.armor_bank_account.account_swift,
    #   'account' => current_user.armor_bank_account.account_account,
    #   'iban' => current_user.armor_bank_account.account_iban
    # })
  end

  def role
    self.roles.all.first
  end

  def self.users
    users = []
    data = User.all.to_a
    data.each do |user|
      users << user.id if user.has_role? :user 
    end
    
    User.where(id: users)
  end

  def mailboxer_email(object)
    email
  end
end
