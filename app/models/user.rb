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

  has_one :armor_bank_account, dependent: :destroy
  accepts_nested_attributes_for :armor_bank_account

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

  after_create :create_armor_bank_account
  after_save :create_armor_profile,
    if: -> { self.name && self.phone },
    unless: -> { self.armor_profile }

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
