class SynapsePay

  attr_reader :client_id, :client_secret, :fingerprint, :ip_address, :development_mode, :webhook_url

  SANDBOX_MODE = !Rails.env.production?
  CURRENCY = 'USD'
  FINGERPRINT = Rails.application.secrets['synapsepay_fingerprint']
  USER_ID = Rails.application.secrets['synapsepay_user_id']
  ESCROW_NODE_ID = Rails.application.secrets['synapsepay_escrow_node_id']
  ESCROW_FEE_HOLDER_NODE_ID = Rails.application.secrets['synapsepay_escrow_fee_holder_node_id']
  SCOPE = ['USERS|POST', 'USERS|PATCH', 'NODES|POST', 'NODES|PATCH', 'NODES|DELETE', 'TRANS|POST', 'TRANS|PATCH', 'TRANS|DELETE'].freeze

  def initialize(fingerprint:, ip_address:)
    @client_id = Rails.application.secrets['synapsepay_client_id']
    @client_secret = Rails.application.secrets['synapsepay_client_secret']
    @fingerprint = fingerprint
    @ip_address = ip_address
    @development_mode = SANDBOX_MODE
    @webhook_url = Rails.application.secrets['synapsepay_webhook_url']

    subscriptions.create
  end

  def client
    options = {
      client_id: client_id,
      client_secret: client_secret,
      fingerprint: fingerprint,
      ip_address: ip_address,
      development_mode: development_mode
    }
    options.merge!(logging: true) if development_mode

    SynapsePayRest::Client.new(options)
  end

  def user(user_id:)
    SynapsePayRest::User.find(client: client, id: user_id)
  end

  def create_user(**options)
    user_create_settings = {
      client: client,
      logins: [{ email: options[:email] }],
      phone_numbers: [options[:phone]],
      legal_names: [options[:name]],
      note: "Create User #{options[:id]} #{options[:name]}",
      is_business: true
    }

    SynapsePayRest::User.create(user_create_settings)
  end

  def subscriptions
    Subscriptions.new(client.http_client, webhook_url)
  end

  private

  Subscriptions = Struct.new(:http_client, :webhook_url) do
    def all
      http_client.get('/subscriptions')
    end

    def create
      data = {
        url: webhook_url,
        scope: SCOPE
      }

      http_client.post('/subscriptions', data)
    end

    def find(id:)
      http_client.get("/subscriptions/#{id}")
    end

    def update(id:, data:)
      http_client.patch("/subscriptions/#{id}", data)
    end
  end
end
