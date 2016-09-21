class FlyBuyService

  def self.get_client(fingerprint, user_id = nil)
    if Rails.env.production?
      sandbox_mode = false
    else
      sandbox_mode = true
    end

    # client = SynapsePayments::Client.new(
    #                     client_id: Rails.application.secrets['fly_buy_client_id'], 
    #                     client_secret: Rails.application.secrets['fly_buy_client_secret'],
    #                     sandbox_mode: sandbox_mode)
    options = {
        'fingerprint' => fingerprint,
        'client_id' => Rails.application.secrets['fly_buy_client_id'],
        'client_secret' => Rails.application.secrets['fly_buy_client_secret'],
        'development_mode' => sandbox_mode
    }

    client = SynapsePayRest::Client.new options: options, user_id: user_id

  end
end