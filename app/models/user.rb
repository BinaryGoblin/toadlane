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

  after_update :create_armor_profile,
    if: -> { self.name && self.phone },
    unless: -> { self.armor_profile }
  after_update :update_armor_api_user, if: :armor_api_user_changed?
  after_update :update_armor_api_account, if: :armor_api_account_changed?

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

  private
  def armor_api_user_changed?
    (self.changed & %w{name email phone}).any?
  end

  def armor_api_account_changed?
    (self.changed & %w{company address city state postal_code country phone}).any?
  end

  def update_armor_api_user
    armor_api.users(self.armor_account_id).update(
      self.armor_user_id,
      user_name: self.name,
      user_phone: self.phone
    )
  end

  def update_armor_api_account
    armor_api.accounts.update(
      self.armor_account_id,
      company:      self.company,
      address:      self.address,
      city:         self.city,
      state:        self.state,
      postal_code:  self.postal_code,
      phone:        self.phone,
      country:      self.country
    )
  end

  def armor_api
    @armor_api_client ||= ArmorService.new.client
  end
end
