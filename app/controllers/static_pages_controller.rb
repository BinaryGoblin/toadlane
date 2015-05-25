class StaticPagesController < ApplicationController
  layout 'user_dashboard'

  def contact_info
    render 'static_pages/contact_info'
  end

  def payment_info
    render 'static_pages/payment_info'
  end

  def faq;end

  def home
    if current_user
      redirect_to products_path
    else
      render 'static_pages/home', layout: 'application'
    end
  end
end