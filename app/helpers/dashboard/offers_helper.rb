module Dashboard::OffersHelper
  def offer_payment_mode(offer)
    class_names = []

    if offer.default_payment_green?
      content_tag :div, class: class_inner
      payment_mode = 'Echeck'
      class_names << 'label label-green'
    elsif offer.default_payment_stripe?
      payment_mode = 'Stripe'
      class_names << 'label label-blue'
    elsif offer.default_payment_amg?
      payment_mode = 'AMG'
      class_names << 'label label-dark-blue'
    elsif offer.default_payment_emb?
      payment_mode = 'EMB'
      class_names << 'label label-dark-blue'
    elsif offer.default_payment_flybuy?
      payment_mode = 'Fly & Buy'
      class_names << 'label label-orange'
    elsif offer.default_payment_same_day?
      payment_mode = 'Same Day'
      class_names << 'label label-orange'
    else
      payment_mode =  'Not selected by seller.'
    end

    content_tag :span, class: class_names do
      payment_mode
    end
  end
end
