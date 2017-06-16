# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  name                   :string
#  phone                  :string
#  company                :string
#  facebook               :string
#  ein_tax                :string
#  receive_private_info   :boolean          default(TRUE)
#  receive_new_offer      :boolean          default(TRUE)
#  receive_tips           :boolean          default(TRUE)
#  asset_file_name        :string
#  asset_file_size        :string
#  asset_content_type     :string
#  created_at             :datetime
#  updated_at             :datetime
#  benefits               :text
#  is_reseller            :boolean          default(FALSE)
#  armor_account_id       :integer
#  armor_user_id          :integer
#  terms_of_service       :boolean
#  terms_accepted_at      :datetime
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#

class User < ActiveRecord::Base
  rolify
  acts_as_messageable
  acts_as_commontator
  acts_as_taggable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
  :recoverable, :rememberable, :trackable, :validatable,
  :omniauthable, :invitable

  has_one :stripe_profile
  has_one :green_profile
  has_one :armor_profile, class_name: 'ArmorProfile', foreign_key: :user_id
  has_one :amg_profile
  has_one :emb_profile
  has_one :stripe_customer
  has_many :addresses
  has_one :fly_buy_profile
  has_many :requests_of_sender, class_name: 'Request', foreign_key: :sender_id
  has_many :requests_of_receiver, class_name: 'Request', foreign_key: :receiver_id
  has_many :notifications, dependent: :destroy
  # user.products -> those products which the user is the owner
  has_many :products
  has_many :groups, foreign_key: 'group_owner_id', class_name: 'Group'
  has_many :group_sellers, dependent: :destroy
  has_one :certificate, dependent: :destroy
  has_and_belongs_to_many :roles,
    :join_table => :users_roles,
    :foreign_key => 'user_id',
    :association_foreign_key => 'role_id'
  has_many :additional_seller_fee_transactions, dependent: :destroy
  has_many :folders, dependent: :destroy

  has_attached_file :asset, styles: {
    small: '155x155#',
    medium: '240x225#'
  },
  default_url: '/assets/avatar/:style/missing.png'
  do_not_validate_attachment_file_type :asset

  validates :terms_of_service, inclusion: { in: [true, false] }
  validates :name, presence: true, on: :create
  validate :validate_phone_number
  validates :tag_list, presence: { message: ': Please let us know what are items you want to buy and sell' }, on: :create
  # validates :benefits, presence: true, on: :update

  accepts_nested_attributes_for :addresses,
    allow_destroy: true,
    reject_if: lambda { |a| (a[:name].empty? && a[:line1].empty? && a[:line2].empty? && a[:city].empty? && a[:state].empty? && a[:zip].empty?) }

  before_destroy { roles.clear }

  serialize :benefits, Array

  scope :product_associated_users, -> (catagory) { where('benefits LIKE ?', "%#{catagory.name}%" ) }
  scope :ordered_by_name, -> { order(name: :asc) }

  # after_create :associate_api_user
  # after_update :create_armor_api_account,
  #  if: -> { self.name && self.phone },
  #  unless: :armor_api_account_persisted?
  # after_update :update_armor_api_user, if: :armor_api_user_changed?
  # after_update :update_armor_api_account, if: :armor_api_account_changed?

  def profile_complete?
    addresses.present? && name.present? && email.present? && phone.present?
    # !self.addresses.nil? && !self.name.nil? && !self.email.nil? && !self.phone.nil?
  end

  def i_buy_and_sell_present?
    tag_list.present?
  end

  # user should have at least one payment method to create products
  def has_payment_account?
    self.stripe_profile.present? || self.green_profile.present? ||
        self.amg_profile.present? || self.emb_profile.present? ||
        self.fly_buy_profile_verified?
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

  def amg_orders(type=nil)
    if type == 'bought'
      AmgOrder.where(buyer_id: self.id)
    elsif type == 'sold'
      AmgOrder.where(seller_id: self.id)
    else
      AmgOrder.where('buyer_id = ? OR seller_id = ?', self.id, self.id)
    end
  end

  def emb_orders(type=nil)
    if type == 'bought'
      EmbOrder.where(buyer_id: self.id)
    elsif type == 'sold'
      EmbOrder.where(seller_id: self.id)
    else
      EmbOrder.where('buyer_id = ? OR seller_id = ?', self.id, self.id)
    end
  end

  def fly_buy_orders(type=nil)
    if type == 'bought'
      FlyBuyOrder.where(buyer_id: self.id)
    elsif type == 'sold'
      FlyBuyOrder.where(seller_id: self.id)
    else
      fly_buy_orders = FlyBuyOrder.where('buyer_id = ? OR seller_id = ?', self.id, self.id)
      fly_buy_orders.where.not(count: nil, status: nil)
    end
  end

  def refund_requests(type=nil)
    if type == 'bought'
      RefundRequest.where(buyer_id: self.id)
    elsif type == 'sold'
      RefundRequest.where(seller_id: self.id)
    else
      RefundRequest.where('buyer_id = ? OR seller_id = ?', self.id, self.id)
    end
  end

  def armor_api_account_persisted?
    self.armor_account_id && self.armor_user_id
  end

  def formatted_phone
    if phone.present?
      phone_number = phone.split(//).last(10).join
      phone_number.insert(3, '-').insert(-5, '-')
      phone_number
    end
  end

  def phone_extension
    if phone.present?
      phone_number = phone.split(//).last(10).join
      phone_extension = phone.split(phone_number).join
    end
  end

  def armor_account_id
    armor_profile.armor_account_id
  end

  def validate_phone_number
    if phone.present?
      phone_number = Phonelib.parse(phone)

      if !phone_number.valid?
        errors.add(:phone, 'number is not valid')
      end
    end
  end

  def default_payment_armor?
    armor_profile.default_payment == true
  end

  def available_payments
    ap = []
    ap << Product::PaymentOptions[:stripe] if stripe_profile.present?
    ap << Product::PaymentOptions[:green] if green_profile.present?
    ap << Product::PaymentOptions[:amg] if amg_profile.present?
    ap << Product::PaymentOptions[:emb] if emb_profile.present?
    ap << Product::PaymentOptions[:fly_buy]

    ap
  end

  def first_name
    name.split(" ")[0]
  end

  def last_name
    name.split(" ")[1]
  end

  def fly_buy_profile_exist?
    fly_buy_profile.present? && fly_buy_profile.synapse_user_id.present? &&
    fly_buy_profile.synapse_node_id.present?
  end

  def fly_buy_profile_account_added?
    fly_buy_profile.present? && fly_buy_profile.completed?
  end

  def fly_buy_verified_by_admin?
    !fly_buy_profile.unverify_by_admin?
  end

  def fly_buy_profile_verified?
    fly_buy_profile_account_added? && fly_buy_verified_by_admin?
  end

  def fly_buy_unverified_by_admin
    fly_buy_profile.unverify_by_admin?
  end

  def fly_buy_profile_processing?
    fly_buy_profile.present? && fly_buy_profile.synapse_node_id.nil? && fly_buy_profile.permission_scope_verified == false
  end

  def fly_buy_profile_active?
    fly_buy_profile.present? && fly_buy_profile.permission_scope_verified && fly_buy_profile.unverify_by_admin == false
  end

  def label_for_select
    if name && company.present?
      name + ", " + company
    else name.present?
      name
    end
  end

  def pending_orders
    fly_buy_orders = self.fly_buy_orders.not_deleted.pending_orders
    stripe_orders = self.stripe_orders.pending_orders
    green_orders = self.green_orders.pending_orders
    amg_orders = self.amg_orders.pending_orders
    emb_orders = self.emb_orders.pending_orders
    user_involved_groups = Group.joins(:group_sellers).where('group_sellers.user_id' => self.id)
    user_involved_orders = FlyBuyOrder.where(group_seller_id: user_involved_groups.ids).where.not(count: nil, status: nil).pending_orders

    return fly_buy_orders + stripe_orders + green_orders + amg_orders + emb_orders + user_involved_orders
  end

  def total_earning
    sell_orders.present? ? sell_orders.collect{ |order| order.total_earning }.reduce(:+) : 0
  end

  def sell_orders
    slord = []
    slord << stripe_orders('sold').completed
    slord << green_orders('sold').completed
    slord << amg_orders('sold').completed
    slord << emb_orders('sold').completed
    slord << fly_buy_orders('sold').completed

    slord.flatten
  end

  def my_products
    products.for_sell.independent
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
