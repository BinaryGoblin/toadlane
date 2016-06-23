class User < ActiveRecord::Base
  rolify
  acts_as_messageable
  acts_as_commontator

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  has_one :stripe_profile
  has_one :green_profile
  has_one :stripe_customer
  has_many :products
  has_many :addresses
  accepts_nested_attributes_for :addresses,
    :allow_destroy => true,
    :reject_if => lambda { |a| (a[:name].empty? && a[:line1].empty? && a[:line2].empty? && a[:city].empty? && a[:state].empty? && a[:zip].empty?) }
  validates :terms_of_service, :inclusion => {:in => [true, false]}
  has_many :requests_of_sender, class_name: 'Request', foreign_key: :sender_id
  has_many :requests_of_receiver, class_name: 'Request', foreign_key: :receiver_id

  has_one :certificate, dependent: :destroy

  has_and_belongs_to_many :roles,
                          :join_table => :users_roles,
                          :foreign_key => 'user_id',
                          :association_foreign_key => 'role_id'

  has_attached_file :asset, styles: {
                                small: '155x155#',
                                medium: '240x225#'
                              },
                              default_url: '/assets/avatar/:style/missing.png'
  do_not_validate_attachment_file_type :asset

  before_destroy { roles.clear }

  serialize :benefits, Array

  # after_create :associate_api_user
  # after_update :create_armor_api_account,
  #  if: -> { self.name && self.phone },
  #  unless: :armor_api_account_persisted?
  # after_update :update_armor_api_user, if: :armor_api_user_changed?
  # after_update :update_armor_api_account, if: :armor_api_account_changed?
  
  def profile_complete?
    !self.addresses.nil? && !self.name.nil? && !self.email.nil? && !self.phone.nil?
  end

  def armor_orders(type=nil)
    if type == 'bought'
      ArmorOrder.where(buyer_id: self.id)
    elsif type == 'sold'
      ArmorOrder.where(seller_id: self.id)
    else
      ArmorOrder.where('buyer_id = ? OR seller_id = ?', self.id, self.id)
    end
  end
  
  def stripe_orders(type=nil)
    if type == 'bought'
      StripeOrder.where(buyer_id: self.id)
    elsif type == 'sold'
      StripeOrder.where(seller_id: self.id)
    else
      StripeOrder.where('buyer_id = ? OR seller_id = ?', self.id, self.id)
    end
  end

  def green_orders(type=nil)
    if type == 'bought'
      GreenOrder.where(buyer_id: self.id)
    elsif type == 'sold'
      GreenOrder.where(seller_id: self.id)
    else
      GreenOrder.where('buyer_id = ? OR seller_id = ?', self.id, self.id)
    end
  end

  def armor_api_account_persisted?
    self.armor_account_id && self.armor_user_id
  end

  private
  def associate_api_user
    if armor_api_account_exists?
      armor_user = armor_api_users.find {|u| u['email'] == self.email }
      self.update_columns(armor_account_id: armor_user['account_id'], armor_user_id: armor_user['user_id'])
    end
  end
  handle_asynchronously :associate_api_user

  def armor_api_account_exists?
    armor_api_users.any? {|u| u['email'] == self.email }
  end

  def armor_api_users
    @armor_api_users ||= armor_api.partner.users(Rails.application.secrets['armor_partner_id']).all.body
  end

  def create_armor_api_account
    response = armor_api.accounts.create({
      user_name: self.name,
      user_email: self.email,
      user_phone: self.phone,
      email_confirmed: true
    })
    populate_armor_fields(response.body["account_id"])
  end
  handle_asynchronously :create_armor_api_account

  def update_armor_api_user
    armor_api.users(self.armor_account_id).update(
      self.armor_user_id,
      user_name: self.name,
      user_phone: self.phone
    )
  end
  handle_asynchronously :update_armor_api_user

  def update_armor_api_account
    armor_api.accounts.update(
      self.armor_account_id,
      company:      self.company,
      address:      self.address,
      city:         self.city,
      state:        self.state,
      postal_code:  self.postal_code,
      phone:        self.phone,
      country:      self.country.downcase # Must be lowercase for ArmorPayments
    )
  end
  handle_asynchronously :update_armor_api_account

  def armor_api_user_changed?
    (self.changed & %w{name email phone}).any?
  end

  def armor_api_account_changed?
    (self.changed & %w{company address city state postal_code country phone}).any?
  end

  def populate_armor_fields(account_id)
    api_user_id = get_api_user(account_id)["user_id"].to_i
    self.update_columns(
      armor_account_id: account_id,
      armor_user_id: api_user_id
    )
  end
  handle_asynchronously :populate_armor_fields

  def get_api_user(id)
    armor_api.users(id).all.body.first
  end

  def armor_api
    @armor_api_client ||= ArmorService.new
  end
end
