module ProductHelper

  def get_shipping_cost(quantity, shipping_cost)
    quantity.to_i * shipping_cost.to_f
  end

  def get_subtotal(unit_price, quantity)
    quantity.to_i * unit_price
  end

  def get_state(user_state)
    selected_state = states.select{ |state| state.first.downcase == user_state.try(:downcase) }
    selected_state.flatten.last
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
end
