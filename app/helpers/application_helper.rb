module ApplicationHelper
  def link link_text, link_path, _class: '', _class_active: ''
    class_name = ''

    class_active = _class_active.present? ? _class_active : 'active '

    if _class.present?
      class_name << _class
    end

    if current_page?(link_path)
      class_name << ' ' + class_active
    end

    link_to link_text, link_path, class: class_name
  end

  def nav_link link_text, link_path
    class_name = current_page?(link_path) ? 'active ' : ''

    content_tag :li do
      link_to link_text, link_path, class: class_name
    end
  end

  def tab_link_to link_text, link_path, is: nil, disabled: false
    class_name = controller.controller_name.to_s == is ? 'btn btn-black' : 'btn btn-default'

    link_to link_text, link_path, class: class_name, role: 'button', disabled: disabled
  end

  def sub_categories_of_product id
    categories = Product.find(id).categories

    if categories.present?
      content_tag :div do
        categories.each_with_index do |category, index|
          concat ', ' if index > 0
          concat link_to category.name, search_index_path(cat_id: category.id, count: 16)
        end
      end
    end
  end

  def products_carousel_items products, class_name=''
    class_inner = ['carousel-inner']

    if class_name.present?
      class_inner << class_name
    end

    content_tag :div, class: class_inner do
      products.each_with_index do |product, index|
        class_item  = ['item']

        if index == 0
          class_item << 'active'
        end

        if index % 4 == 0
          concat tag 'div', class: class_item
        end

        concat render partial: '/shared/product', locals: { product: product }

        if index % 4 == 3 || index == products.count - 1
          concat tag '/div'
        end
      end
    end
  end

  def sellers_carousel_items sellers, class_name=''
    class_inner = ['carousel-inner']

    if class_name.present?
      class_inner << class_name
    end

    content_tag :div, class: class_inner do
      sellers.each_with_index do |seller, index|
        class_item  = ['item']

        if index == 0
          class_item << 'active'
        end

        if index % 4 == 0
          concat tag 'div', class: class_item
        end

        concat render partial: '/shared/seller', locals: { seller: seller }

        if index % 4 == 3 || index == sellers.count - 1
          concat tag '/div'
        end
      end
    end
  end

  def time_left end_time
    start_time = Time.now

    if end_time - start_time < 0
      content_tag :div, 'Time ended'
    else
      diff_general = TimeDifference.between(start_time, end_time).in_general
      diff_days = TimeDifference.between(start_time, end_time).in_days.to_i

      days = content_tag :div, class: 'days' do
        concat content_tag :span, diff_days
        concat content_tag :span, 'days'
      end

      hours = content_tag :div, class: 'hours' do
        concat content_tag :span, diff_general[:hours]
        concat content_tag :span, 'hours'
      end

      minutes = content_tag :div, class: 'min' do
        concat content_tag :span, diff_general[:minutes]
        concat content_tag :span, 'min.'
      end

      seconds = content_tag :div, class: 'sec' do
        concat content_tag :span, diff_general[:seconds]
        concat content_tag :span, 'sec.'
      end
        
      content_tag :div, class: 'time' do
        days + hours + minutes + seconds
      end
    end
  end

  def pricebreak_table pricebreaks, unit_price, available
    trs = ''
    needed = 1
    pricebreaks = pricebreaks.order('quantity asc')

    pricebreaks.each_with_index do |pricebreak, index|
      quantityPrev = pricebreaks[index-1]
      quantityNext = pricebreaks[index+1]

      if index == 0
        trs += content_tag :tr do
          concat content_tag :td, needed.to_s + ' - ' + (pricebreak.quantity).to_s
          concat content_tag :td, '$ ' + unit_price.round.to_s
          concat content_tag :td, needed.to_s + ' needed'
        end
      end

      if quantityPrev.present?
        if available > pricebreak.quantity && quantityNext.present?
          if quantityNext.quantity > available
            last_quantity = available.to_s
          else
            last_quantity = quantityNext.quantity.to_s
          end

        elsif available > pricebreak.quantity
          last_quantity = available.to_s

        else
          last_quantity = ''
        end
      else
        last_quantity = ''
      end
      
      tr_first = (pricebreak.quantity + 1).to_s + ' - ' + last_quantity
      tr_second = '$ ' + pricebreak.price.round.to_s
      tr_third = (pricebreak.quantity + 1).to_s + ' needed'

      needed = pricebreak.quantity + 1

      trs += content_tag :tr do
        concat content_tag :td, tr_first
        concat content_tag :td, tr_second
        concat content_tag :td, tr_third
      end
    end

    content_tag :table, content_tag(:tbody, trs.html_safe)
  end

  def slider_pricebreaks pricebreaks, unit_price
    pricebreaks = pricebreaks.order('quantity asc')

    medium = ((pricebreaks.last.quantity || 0) / 2).round
    max = pricebreaks.last.quantity

    options_pricebreak = '"pricebreaks":' + pricebreaks.map { |p| { price: p.price, quantity: p.quantity } }.to_json

    options = '{"max":"' + max.to_s + '","unit_price":"' + unit_price + '",' + options_pricebreak + '}'

    rates = content_tag :div, class: 'rates', data: { behavior: 'SliderRates', options: options } do
      concat content_tag :span, '1', class: 'min'
      concat content_tag :span, medium, class: 'medium'
      concat content_tag :span, max, class: 'max'
    end

    quantity = content_tag :div, class: 'quantity' do
      concat content_tag :div, 'Quantity:', class: 'lbl'
      concat rates
    end

    cost = content_tag :div, class: 'cost' do
      concat content_tag :div, 'Cost:', class: 'lbl'
      concat content_tag :span, number_to_currency(unit_price, precision: 2, unit: '$', separator: ',', delimiter: ''), class: 'pb-cost'
    end

    you_save = content_tag :div, class: 'you_save' do
      concat content_tag :div, 'You save:', class: 'lbl'
      concat content_tag :span, '$0,00', class: 'pb-save'
    end

    quantity + cost + you_save
  end

  def get_user_by_id id
    User.find id
  end

  def main_categories
    Category.where(parent_id: nil).order(:id)
  end

  def taxes
    if current_user.is_reseller
      Tax.all.order(:value)
    else
      Tax.where.not(value: 0).order(:value)    
    end
  end
end
