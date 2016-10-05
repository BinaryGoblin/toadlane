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

  def all_categories_of_product id
    product = Product.find(id)

    content_tag :div do
      concat link_to product.category.name, search_path(cat_id: product.category.id, count: 16) if product.category.present?
      if product.categories.present?
        product.categories.each do |category|
          if category.name == "all"
            concat link_to category.name, search_path(cat_id: category.id, count: 16)
          else
            concat ', '
            concat link_to category.name, search_path(cat_id: category.id, count: 16)
          end
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
          concat content_tag :td, number_with_delimiter(needed) + ' - ' + (number_with_delimiter(pricebreak.quantity - 1))
          concat content_tag :td, number_to_currency(unit_price)
          concat content_tag :td, number_with_delimiter(needed) + ' needed'
        end
      end

      if quantityPrev.present?
        if available > pricebreak.quantity && quantityNext.present?
          if quantityNext.quantity > available
            last_quantity = available.to_s
          else
            last_quantity = (quantityNext.quantity - 1).to_s
          end

        elsif available > pricebreak.quantity
          last_quantity = available.to_s

        else
          last_quantity = ''
        end
      else
        last_quantity = ''
      end

      tr_first = number_with_delimiter((pricebreak.quantity)) + ' - ' + number_with_delimiter(last_quantity)
      tr_second = number_to_currency(pricebreak.price)
      tr_third = number_with_delimiter((pricebreak.quantity)) + ' needed'

      needed = pricebreak.quantity

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
      concat content_tag :span, number_to_currency(unit_price, precision: 2, unit: '$'), class: 'pb-cost'
    end

    you_save = content_tag :div, class: 'you_save' do
      concat content_tag :div, 'You save:', class: 'lbl'
      concat content_tag :span, '$0.00', class: 'pb-save'
    end

    quantity + cost + you_save
  end

  def get_user_by_id id
    User.find id
  end

  def main_categories
    Category.where(parent_id: nil).order("lower(name) ASC")
  end

  def all_category
    Category.where(name: "all").last
  end

  def taxes
    if current_user.is_reseller
      Tax.all.order(:value)
    else
      Tax.where.not(value: 0).order(:value)
    end
  end

  def product_border_color(product)
    if product.present?
      product.status_characteristic == "sell" ? "green_border" : "orange_border"
    end
  end

  def product_button_color(product)
	  if product.present?
	    product.status_characteristic == "sell" ? "btn btn-success" : "btn btn-success-sell"
	  end
  end

  def get_user_notifications
    notifications = get_user_unread_message_notifications
    # TODO
    # notifications += get_user_new_order_notifications

    notifications
  end

  def get_user_unread_message_notifications
    unread_receipts ||= current_user.mailbox.receipts.where(is_read: 'false')

    if unread_receipts
      unread_receipts.count
    else
      0
    end
  end

  def is_cancellable?(order)
    order.is_a?(GreenOrder) && order.status == "placed" && current_user.id == order.buyer_id && order.refund_request.nil?
  end

  def refund_requested?(order)
    order.is_a?(GreenOrder) && order.status == "challenged" && current_user.id == order.buyer_id && order.refund_request.present?
  end
end
