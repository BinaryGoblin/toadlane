Toad::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  #-----------------------
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.delivery_method = :smtp
  routes.default_url_options = { host: 'localhost:3000' }
  ActionMailer::Base.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    authentication: "plain",
    enable_starttls_auto: true,
    # user_name: "jyaasaruby@gmail.com",
    # password: "p@ssword123"
  }
  #-----------------------
  config.action_mailer.default_url_options = { :host => "localhost:3000" }

  ENV['STRIPE_CLIENT_ID'] = 'ca_84wji8nX79sEzFhHa9WifOU5d69WNSVs'
  ENV['STRIPE_API_KEY'] = 'sk_test_Ejq6XT0escvFPGdciJ4DMECe'
  ENV['STRIPE_PUBLISHABLE_KEY'] = 'pk_test_UpoMrqANqaQo5mx61CDvk9aH'

  #config aws for production ENV file storage
  config.paperclip_defaults = {
     :storage => :s3,
     :s3_credentials => {
        # :s3_host_name => 's3-us-west-2.amazonaws.com',
        :bucket => 'staging-toad',
        :access_key_id => 'AKIAJBUNG3ZF7WAMUW5A',
        :secret_access_key => '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'
     }
  }

  Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
  Paperclip::Attachment.default_options[:path] = 'development/:class/:attachment/:id_partition/:style/:filename'

  Paperclip::Attachment.default_options[:s3_host_name] = 's3-us-west-2.amazonaws.com'

end
