class FlyBuyService

  if Rails.env.production?
    SandboxMode = false
  else
    SandboxMode = true
  end

  if Rails.env.development?
    ClientId = Rails.application.secrets['SYNAPSEPAY_CLIENT_ID']
    ClientSecret = Rails.application.secrets['SYNAPSEPAY_CLIENT_SECRET']
    WebhookUrl = Rails.application.secrets['SYNAPSEPAY_WEBHOOK_URL']
  else
    ClientId = ENV['SYNAPSEPAY_CLIENT_ID']
    ClientSecret = ENV['SYNAPSEPAY_CLIENT_SECRET']
    WebhookUrl = ENV['SYNAPSEPAY_WEBHOOK_URL']
  end

  def self.get_client
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

  def self.create_subscription
    puts `curl -X POST -H "Content-Type: application/json" -H "X-SP-GATEWAY: #{ClientId}|#{ClientSecret}" -H "X-SP-PROD: NO" -H "X-SP-LANG: EN" -d '{
        "url":"#{WebhookUrl}",
        "scope":[
          "USERS|POST",
          "USERS|PATCH",
          "USERS|DELETE",
          "NODES|POST",
          "NODES|PATCH",
          "NODES|DELETE",
          "TRANS|POST",
          "TRANS|PATCH",
          "TRANS|DELETE"
        ]
    }' 'https://sandbox.synapsepay.com/api/3/subscriptions'`
  end
end