class FlyBuyService

  def self.get_client
    if Rails.env.production?
      sandbox_mode = false
    else
      sandbox_mode = true
    end

    if Rails.env.development?
      client_id = Rails.application.secrets['SYNAPSEPAY_CLIENT_ID']
      client_secret = Rails.application.secrets['SYNAPSEPAY_CLIENT_SECRET']
    else
      client_id = ENV['SYNAPSEPAY_CLIENT_ID']
      client_secret = ENV['SYNAPSEPAY_CLIENT_SECRET']
    end

    timeout_options = { write: 50, connect: 50, read: 50 }

    SynapsePayments::Client.new(
                        client_id: client_id,
                        client_secret: client_secret,
                        sandbox_mode: sandbox_mode, 
                        timeout_options: timeout_options)

  end
end