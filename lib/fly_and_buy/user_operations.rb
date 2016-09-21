class FlyAndBuy::UserOperations

  attr_accessor :user, :user_details, :client

  # user => current user
  # user_details => {"name_on_account"=>"asdasd", "account_num"=>"34343434", "fingerprint"=>"422738736",
  #                   "routing_num"=>"343434", "account_type"=>"savings", "holder_type"=>"business"}
  def initialize(user, user_details = {})
    @user = user
    @user_details = user_details
    @client = FlyBuyService.get_client(user_details["fingerprint"])
  end

  def create_user
    create_payload
  end

  private

  def create_payload
    binding.pry
    payload = {
        "logins" =>  [
            {
                "email" =>  user.email
            }
        ],
        "phone_numbers" =>  [
            user.phone
        ],
        "legal_names" =>  [
            user.name
        ],
        "extra" =>  {
            "supp_id" =>  generate_sup_id,
            "is_business" =>  is_business?
        }
    }
    create_response = client.users.create(payload: payload)

    update_payload = {
        "refresh_token" => create_response["refresh_token"],
        "update" => {
            "login" => {
                "email" => user.email,
                "password" => user_details["password"],
            },
            "phone_number" => user.phone,
            "legal_name" => user.name
        }
    }

    update = client.users.update(payload: update_payload)

    oauth_payload = {
        "refresh_token" =>  create_response["refresh_token"]
    }
    oauth_response = client.users.refresh(payload: oauth_payload)
    binding.pry

    acct_rout_payload = {
        "type" => "ACH-US",
        "info" => {
            "nickname" => "Ruby Library Savings Account",
            "name_on_account" => user_details["name_on_account"],
            "account_num" => user_details["account_num"],
            "routing_num" => user_details["routing_num"],
            "type" => user_details["account_type"],
            "class" => user_details["holder_type"]
        },
        "extra" => {
            "supp_id" => generate_sup_id
        }
    }

    acct_rout_response = client.nodes.add(payload: acct_rout_payload)
  end

  def create_bank_account

  end

  def store_returned_id(create_response)
    FlyBuyProfile.create({
      synapse_user_id: create_response["_id"],
      user_id: user.id
      })
  end

  def generate_sup_id
    if Rails.env.development?
      'dev_' + user.id.to_s
    elsif Rails.env.staging?
      'stag_' + user.id.to_s
    else
      user.id
    end
  end

  def is_business?
    user_details["holder_type"] == "business"
  end
end