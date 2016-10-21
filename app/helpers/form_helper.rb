module FormHelper
  def setup_user(user)
    1.times { user.addresses.build }
    user
  end
  
  def setup_product(product)
    1.times { product.shipping_estimates.build }
    product
  end

  def user_entity_types
  	[
  		['Male', 'M'],
  		['Female', 'F'],
  		['Other', 'o'],
  		['NOT_KNOWN', 'Do not wish to specify']
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

  def user_company_entity_scopes
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
end