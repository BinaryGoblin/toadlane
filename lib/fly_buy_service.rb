class FlyBuyService

  if Rails.env.production?
    SandboxMode = false
  else
    SandboxMode = true
  end

  if Rails.env.development?
    ClientId = Rails.application.secrets['SYNAPSEPAY_CLIENT_ID']
    ClientSecret = Rails.application.secrets['SYNAPSEPAY_CLIENT_SECRET']
  else
    ClientId = ENV['SYNAPSEPAY_CLIENT_ID']
    ClientSecret = ENV['SYNAPSEPAY_CLIENT_SECRET']
  end

  def self.get_client

    # timeout_options = { write: 50, connect: 50, read: 50 }

    # client = SynapsePayments::Client.new(
    #                     client_id: ClientId,
    #                     client_secret: ClientSecret,
    #                     sandbox_mode: sandbox_mode, 
    #                     timeout_options: timeout_options)

    # client.subscriptions.create(url: 'http://requestb.in/w3n7h9w3', scope: ['USERS|POST', 'NODES|POST', 'TRANS|POST'])

    # client

    options = {
      'client_id' => ClientId,
      'client_secret' => ClientSecret,
      'development_mode' => SandboxMode}

    client = SynapsePayRest::Client.new options: options

  end

  def self.get_user(oauth_key:, fingerprint:, ip_address:, user_id:)
    options = {
    'oauth_key' => oauth_key,
    'fingerprint' => fingerprint,
    'client_id' => ClientId,
    'client_secret' => ClientSecret,
    'ip_address' => ip_address,
    'development_mode' => true}


    SynapsePayRest::Client.new options: options, user_id: user_id
  end
end