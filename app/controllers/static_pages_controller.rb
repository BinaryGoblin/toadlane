class StaticPagesController < ApplicationController
  layout 'user_dashboard'

  def contact_info
    render 'static_pages/contact_info'
  end

  def payment_info
    render 'static_pages/payment_info'
  end

  def faq;end
  def escrow_faq
  end

  def toadlane_trust
  end
  
  def faque
  end

  def home
    if current_user
      redirect_to products_path
    else
      redirect_to new_user_registration_path
    end
  end

  def terms_of_service
  end

  def account_deactivated
    render 'static_pages/account_deactivated'
  end
end
