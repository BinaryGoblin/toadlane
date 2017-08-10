class SynapsePay

  attr_reader :client_id, :client_secret, :fingerprint, :ip_address, :development_mode, :webhook_url

  SANDBOX_MODE = !Rails.env.production?
  CURRENCY = 'USD'
  FINGERPRINT = Rails.application.secrets['synapsepay_fingerprint']
  USER_ID = Rails.application.secrets['synapsepay_user_id']
  ESCROW_NODE_ID = Rails.application.secrets['synapsepay_escrow_node_id']
  ESCROW_FEE_HOLDER_NODE_ID = Rails.application.secrets['synapsepay_escrow_fee_holder_node_id']
  SCOPE = ['USERS|POST', 'USERS|PATCH', 'NODES|POST', 'NODES|PATCH', 'NODES|DELETE', 'TRANS|POST', 'TRANS|PATCH', 'TRANS|DELETE'].freeze

  DOC_TYPES = {
    ssn: 'SSN',
    ein: 'EIN_DOC',
    bank_statement: 'PROOF_OF_ACCOUNT',
    address_proof: 'PROOF_OF_ADDRESS',
    gov_id: 'GOVT_ID',
    ssn_card: 'SSN_CARD',
    tin: 'TIN',
    business_documents: 'OTHER'
  }.freeze

  def initialize(fingerprint:, ip_address:, dynamic_fingerprint:)
    @client_id = Rails.application.secrets['synapsepay_client_id']
    @client_secret = Rails.application.secrets['synapsepay_client_secret']
    @fingerprint = Rails.application.secrets['synapsepay_fingerprint']
    @ip_address = ip_address
    @development_mode = SANDBOX_MODE
    @webhook_url = Rails.application.secrets['synapsepay_webhook_url']
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
    create_or_update_subscription

    SynapsePayRest::User.find(client: client, id: user_id)
  end

  def create_user(**options)
    create_or_update_subscription

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

  private

  def create_or_update_subscription
    subscription = SynapsePaySubscription.first
    if subscription.present?
      synapse_pay_subscription = find_and_update_subscription(subscription.subscription_id)
      unless synapse_pay_subscription
        subscription.destroy
        create_or_update_subscription
      end
    else
      synapse_pay_subscription = create_subscription
      SynapsePaySubscription.create(subscription_id: synapse_pay_subscription.id)
      synapse_pay_subscription
    end
  end

  def find_and_update_subscription(subscription_id)
    if subscription_id.present?
      subscription = SynapsePayRest::Subscription.find(client: client, id: subscription_id)
      subscription = SynapsePayRest::Subscription.update(client: client, is_active: true, url: webhook_url, scope: SCOPE) if subscription && !subscription.is_active
      subscription
    end
  end

  def create_subscription
    SynapsePayRest::Subscription.create(client: client, url: webhook_url, scope: SCOPE)
  end
end
