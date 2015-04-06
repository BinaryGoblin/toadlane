class ArmorProfile < ActiveRecord::Base
  belongs_to :user
  after_save :create_armor_api_account, unless: :armor_account_exists?

  def client
    @client ||= service.client
  end

  def service
    @service ||= ArmorService.new
  end

  def create_armor_api_account
    response = client.accounts.create({
      user_name: user.name,
      user_email: user.email,
      user_phone: user.phone
    })
    populate_armor_fields(response.body["account_id"])
  end

  def populate_armor_fields(account_id)
    api_user_id = get_api_user(account_id)["user_id"].to_i
    self.update_attributes(
      armor_account_id: account_id,
      armor_user: api_user_id
    )
  end

  def get_api_user(id)
    client.users(id).all.body.first
  end

  def armor_account_exists?
    armor_account_id && armor_user_id ? true : false
  end
end
