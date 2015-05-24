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
    redirect_to products_path if current_user
    render 'static_pages/home', layout: 'application'
  end
end