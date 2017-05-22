module ProductHelper

  def payment_verified?(product)
    default_payment = product.default_payment.downcase.to_sym
    owner = product.owner
    if default_payment == :fly_buy
      owner.fly_buy_profile_account_added?
    elsif default_payment == :stripe
      owner.stripe_profile.present?
    elsif default_payment == :green
      owner.green_profile.present?
    elsif default_payment == :amg
      owner.amg_profile.present?
    end
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
    current_user.products.collect{|p| p.views_count}.sum
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
end
