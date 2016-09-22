class FlyBuyService

  def self.get_client
    if Rails.env.production?
      sandbox_mode = false
    else
      sandbox_mode = true
    end

    timeout_options = { write: 100, connect: 100, read: 100 }

    SynapsePayments::Client.new(
                        client_id: Rails.application.secrets['fly_buy_client_id'], 
                        client_secret: Rails.application.secrets['fly_buy_client_secret'], 
                        sandbox_mode: sandbox_mode, 
                        timeout_options: timeout_options)

    # client = SynapsePayments::Client.new(
    #                     client_id: Rails.application.secrets['fly_buy_client_id'], 
    #                     client_secret: Rails.application.secrets['fly_buy_client_secret'],
    #                     sandbox_mode: sandbox_mode)
    # options = {
    #     'client_id' => Rails.application.secrets['fly_buy_client_id'],
    #     'client_secret' => Rails.application.secrets['fly_buy_client_secret'],
    #     'development_mode' => sandbox_mode,
    #     'oauth_key' => oauth_key,
    #     'fingerprint' => fingerprint,
    #     'ip_address' => ip_address
    # }

    # client = SynapsePayRest::Client.new options: options, user_id: user_id

  end
end