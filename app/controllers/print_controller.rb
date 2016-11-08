class PrintController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_terms_of_service
  layout 'print'

  def invoice
    case params[:type]
    when 'stripe'
      @order = StripeOrder.find(params[:id])
    when 'green'
      @order = GreenOrder.find(params[:id])
    when 'amg'
      @order = AmgOrder.find(params[:id])
    when 'emb'
      @order = EmbOrder.find(params[:id])
    when 'fly_buy'
      @order = FlyBuyOrder.find(params[:id])
    else
      @order = StripeOrder.find(params[:id])
    end      
  end
end