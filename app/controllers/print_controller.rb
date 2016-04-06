class PrintController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_terms_of_service
  layout 'print'

  def invoice
    case params[:type]
    when 'stripe'
      @order = StripeOrder.find(params[:id])
    when 'armor'
      @order = ArmorOrder.find(params[:id])
    else
      @order = StripeOrder.find(params[:id])
    end      
  end
end