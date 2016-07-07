class GreenOrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_terms_of_service

  def show
    @green_order = GreenOrder.find(params[:id])
  end

  def create

  end

end
