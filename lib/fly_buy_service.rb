class FlyBuyService

  def self.get_client
    if Rails.env.production?
      sandbox_mode = false
    else
      sandbox_mode = true
    end

    timeout_options = { write: 50, connect: 50, read: 50 }

    SynapsePayments::Client.new(
                        client_id: Rails.application.secrets['fly_buy_client_id'], 
                        client_secret: Rails.application.secrets['fly_buy_client_secret'], 
                        sandbox_mode: sandbox_mode, 
                        timeout_options: timeout_options)

  end
end