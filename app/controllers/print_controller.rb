class PrintController < ApplicationController
  layout 'print'

  def invoice
    @order = ArmorOrder.find(params[:id])
  end
end