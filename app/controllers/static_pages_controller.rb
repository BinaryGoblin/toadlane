class StaticPagesController < ApplicationController
  def contact_info;end
  def payment_info;end
  def faq;end

  def home
    redirect_to products_path if current_user
  end
end