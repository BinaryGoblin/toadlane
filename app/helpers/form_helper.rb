module FormHelper
  def setup_user(user)
    1.times { user.addresses.build }
    user
  end

  def setup_product(product)
    1.times { product.shipping_estimates.build }
    product
  end

  def user_identification_program_options
    [
      ['Tier 1: Up to $100k/month', 'tier_1'],
      ['Tier 2: Up to $500k/month', 'tier_2'],
      ['Tier 3: $1M+/month', 'tier_3']
    ]
  end

  def user_entity_types
  	[
  		['Male', 'M'],
  		['Female', 'F'],
  		['Other', 'O'],
  		['Do not wish to specify', 'NOT_KNOWN']
  	]
  end

  def company_entity_types
  	[
  		['Limited Liability Company', 'LLC'],
  		['Corporation', 'CORP'],
  		['Any type of partnership', 'PARTNERSHIP'],
  		['Sole proprietorship', 'SOLE-PROPRIETORSHIP'],
  		['Trust', 'TRUST'],
  		['Estate', 'ESTATE']
  	]
  end

  def company_entity_scopes
  	[
  		['Not Known', 'Not Known'],
  		['Business Services', 'Business Services'],
  		['Government Organization', 'Government Organization'],
  		['Local Business', 'Local Business'],
  		['Transportation', 'Transportation'],
  		['University', 'University'],
  		['Organization', 'Organization'],
  		['Retail and Consumer Merchandise', 'Retail and Consumer Merchandise'],
  		['Small Business', 'Small Business'],
  		['Telecommunication', 'Telecommunication'],
  		['Transport/Freight', 'Transport/Freight']
  		# ['Airport', 'Airport'],
  		# ['Arts & Entertainment', 'Arts & Entertainment'],
  		# ['Automotive', 'Automotive'],
  		# ['Bank & Financial Services', 'Bank & Financial Services'],
  		# ['Bar', 'Bar'],
  		# ['Book Store', 'Book Store'],
  		# ['Religious Organization', 'Religious Organization'],
  		# ['Club', 'Club'],
  		# ['Community/Government', 'Community/Government'],
  		# ['Concert Venue', 'Concert Venue'],
  		# ['Doctor', 'Doctor'],
  		# ['Event Planning/Event Services', 'Event Planning/Event Services'],
  		# ['Food/Grocery', 'Food/Grocery'],
  		# ['Health/Medical/Pharmacy', 'Health/Medical/Pharmacy'],
  		# ['Home Improvement', 'Home Improvement'],
  		# ['Hospital/Clinic', 'Hospital/Clinic'],
  		# ['Hotel', 'Hotel'],
  		# ['Landmark', 'Landmark'],
  		# ['Lawyer', 'Lawyer'],
  		# ['Library', 'Library'],
  		# ['Licensed Financial Representative', 'Licensed Financial Representative'],
  		# ['Middle School', 'Middle School'],
  		# ['Movie Theater', 'Movie Theater'],
  		# ['Museum/Art Gallery', 'Museum/Art Gallery'],
  		# ['Pet Services', 'Pet Services'],
  		# ['Professional Services', 'Professional Services'],
  		# ['Public Places', 'Public Places'],
  		# ['Real Estate', 'Real Estate'],
  		# ['Restaurant/Cafe', 'Restaurant/Cafe'],
  		# ['School', 'School'],
  		# ['Shopping/Retail', 'Shopping/Retail'],
  		# ['Spas/Beauty/Personal Care', 'Spas/Beauty/Personal Care'],
  		# ['Sports Venue', 'Sports Venue'],
  		# ['Sports/Recreation/Activities', 'Sports/Recreation/Activities'],
  		# ['Tours/Sightseeing', 'Tours/Sightseeing'],
  		# ['Train Station', 'Train Station'],
  		# ['Aerospace/Defense', 'Aerospace/Defense'],
  		# ['Automobiles and Parts', 'Automobiles and Parts'],
  		# ['Bank/Financial Institution', 'Bank/Financial Institution'],
  		# ['Biotechnology', 'Biotechnology'],
  		# ['Cause', 'Cause'],
  		# ['Chemicals', 'Chemicals'],
  		# ['Community Organization', 'Community Organization'],
  		# ['Company', 'Company'],
  		# ['Computers/Technology', 'Computers/Technology'],
  		# ['Consulting/Business Services', 'Consulting/Business Services'],
  		# ['Education', 'Education'],
  		# ['Elementary School', 'Elementary School'],
  		# ['Energy/Utility', 'Energy/Utility'],
  		# ['Engineering/Construction', 'Engineering/Construction'],
  		# ['Farming/Agriculture', 'Farming/Agriculture'],
  		# ['Food/Beverages', 'Food/Beverages'],
  		# ['Health/Beauty', 'Health/Beauty'],
  		# ['Health/Medical/Pharmaceuticals', 'Health/Medical/Pharmaceuticals'],
  		# ['Industrials', 'Industrials'],
  		# ['Insurance Company', 'Insurance Company'],
  		# ['Internet/Software', 'Internet/Software'],
  		# ['Legal/Law', 'Legal/Law'],
  		# ['Media/News/Publishing', 'Media/News/Publishing'],
  		# ['Mining/Materials', 'Mining/Materials'],
  		# ['Non-Governmental Organization (NGO)', 'Non-Governmental Organization (NGO)'],
  		# ['Non-Profit Organization', 'Non-Profit Organization'],
  		# ['Political Organization', 'Political Organization'],
  		# ['Political Party', 'Political Party'],
  		# ['Preschool', 'Preschool'],
  		# ['Travel/Leisure', 'Travel/Leisure']
  	]
  end

  alias_method :user_entity_scopes, :company_entity_scopes

  def get_type(order)
    if order.instance_of? FlyBuyOrder
      'fly_buy'
    elsif order.instance_of? GreenOrder
      'green'
    elsif order.instance_of? StripeOrder
      'stripe'
    elsif order.instance_of? AmgOrder
      'amg'
    elsif order.instance_of? EmbOrder
      'emb'
    end
  end

  def get_selected_role(user)
    existed_role = user.roles.all.map &:name
    if existed_role.include?'group admin'
      selected_role = user.roles.find_by_name('group admin')
      selected_role_id = selected_role.id
    elsif existed_role.include?'public seller'
      selected_role = user.roles.find_by_name('public seller')
      selected_role_id = selected_role.id
    elsif existed_role.include?'private seller'
      selected_role = user.roles.find_by_name('private seller')
      selected_role_id = selected_role.id
    elsif existed_role.include?'public supplier'
      selected_role = user.roles.find_by_name('public supplier')
      selected_role_id = selected_role.id
    elsif existed_role.include?'private supplier'
      selected_role = user.roles.find_by_name('private supplier')
      selected_role_id = selected_role.id
    else
      selected_role_id = nil
    end

    selected_role_id
  end

  def get_additional_seller_roles
    role = []
    role << Role.find_by_name('group admin')
    role << Role.find_by_name('public seller')
    role << Role.find_by_name('private seller')
    role << Role.find_by_name('public supplier')
    role << Role.find_by_name('private supplier')

    role
  end

  def get_current_user_product(user, product_id=nil)
    if product_id == nil
      products = user.products - user.products.joins(:group)
    else
      products =  user.products - user.products.joins(:group)
      product = Product.find_by_id(product_id)
      products << product
    end
    products
  end

  def get_seller_fee_value(group_seller_id)
    if group_seller_id.present?
      group_seller = GroupSeller.find(group_seller_id)

      if group_seller.present?
        group_seller.fee
      end
    end
  end
end