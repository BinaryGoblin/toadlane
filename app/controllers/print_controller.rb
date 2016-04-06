class PrintController < ApplicationController
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