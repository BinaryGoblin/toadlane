module ProductHelper

  def display_error_message
    str = case params[:error]
    when 'profile_not_completed'
      "You must complete your #{link_to 'profile', dashboard_profile_path, class: 'view'} to create order."
    when 'no_company_info'
      "You must add your company name prior to submitting your company information. #{link_to 'Click Here To Edit', dashboard_profile_path(req_company: true), class: 'view'}"
    when 'minimum_order_quantity'
      "To place order you must select minimum #{@product.minimum_order_quantity} units for this product"
    when 'unverified_by_admin'
      'You cannot currently use Fly & Buy services. Please contact hello@toadlane.com for more information.'
    when 'no_fly_buy_profile'
      "Please add a #{link_to('Fly & Buy account', dashboard_accounts_path, class: 'view')} to place your order."
    when 'no_same_day_profile'
      "Please add a #{link_to('Same Day Pay account', dashboard_accounts_path, class: 'view')} to place your order."
    when 'no_strip_profile'
      "Please add a #{link_to('Stripe account', dashboard_accounts_path, class: 'view')} to place your order."
    when 'no_green_profile'
      "Please add a #{link_to('Green By Phone account', dashboard_accounts_path, class: 'view')} to place your order."
    when 'no_amg_profile'
      "Please add a #{link_to('Advanced Merchant Group account', dashboard_accounts_path, class: 'view')} to place your order."
    when 'no_emb_profile'
      "Please add a #{link_to('eMerchant Broker account', dashboard_accounts_path, class: 'view')} to place your order."
    end

    error_template(str.html_safe) unless str.blank?
  end

  def error_template(msg)
    close_btn = content_tag(:button, type: 'button', class: 'close', 'data-dismiss': 'alert', 'aria-label': 'Close') do
      content_tag(:span, raw('&times;'), 'aria-hidden': 'true')
    end
    content_tag :div, class: 'error-explanation text-center alert alert-warning' do
      concat close_btn
      concat msg
    end.html_safe
  end

  def get_shipping_cost(quantity, shipping_cost)
    quantity.to_i * shipping_cost.to_f
  end

  def get_subtotal(unit_price, quantity)
    quantity.to_i * unit_price
  end

  def get_state(user_state)
    if user_state.present? && user_state.length > 2
      selected_state = states.select{ |state| state.first.downcase == user_state.try(:downcase) }
      selected_state.flatten.last
    else
      user_state.try(:upcase)
    end
  end

  def only_us_and_canada
    Carmen::Country.all.select{|c| %w{US CA}.include?(c.code)}
  end

  def states
    [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY'],
      ['British Columbia', 'BC'],
      ['Ontario', 'ON'],
      ['Newfoundland and Labrador', 'NL'],
      ['Nova Scotia', 'NS'],
      ['Prince Edward Island', 'PE'],
      ['New Brunswick', 'NB'],
      ['Quebec', 'QC'],
      ['Manitoba', 'MB'],
      ['Saskatchewan', 'SK'],
      ['Alberta', 'AB'],
      ['Northwest Territories', 'NT'],
      ['Nunavut', 'NU'],
      ['Yukon Territory', 'YT']
    ]
  end

  def product_views_text(count)
    "#{count} Product Views"
  end

  def assignable_users_collection
    user_ids = StripeProfile.pluck(:user_id)
    user_ids << GreenProfile.pluck(:user_id)
    user_ids << FlyBuyProfile.pluck(:user_id)
    user_ids << AmgProfile.pluck(:user_id)
    user_ids = user_ids.compact
    User.where(id: user_ids)
  end

  def get_style(product)
    if product.default_payment_flybuy?
      "display:block;"
    else
      "display:none;"
    end
  end

  def total_viewers
    current_user.products.for_sell.collect{|p| p.views_count}.sum
  end

  def available_products_for_user
    current_user.products.available_products
  end

  def total_earning
    current_user.total_earning
  end

  def get_all_tags
    ActsAsTaggableOn::Tag.all
  end

  def is_a_group_product? product
    product.group.present?
  end

  def percentage_value_for_inspection
    values = []
    0.step(100, 25) { |n| values << "#{n}%"}
    values
  end

  def show_account_status(product)
    case product.default_payment
    when Product::PaymentOptions[:fly_buy]
      text = case product.owner.fly_buy_profile.profile_type
      when 'tier_1'
        'up to $100k'
      when 'tier_2'
        'up to $500k'
      when 'tier_3'
        '$1M+'
      end

      "Verified- #{text}"
    else
      'Verified'
    end
  end
end
