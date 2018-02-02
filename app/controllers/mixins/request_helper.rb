module Mixins
  module RequestHelper
    private

    def new_request
      if params[:product].present?
        @request = Product.new(request_params)
      else
        @request = Product.new
      end
    end

    def edit_request
      @history = PaperTrail::Version.where(item_id: @request.id).order('created_at DESC')
    end

    def create_request
      params[:product].merge!(start_date: DateTime.now)

      product_service = Services::Crud::Product.new(request_params, request_creator)
      @request = product_service.product
      respond_to do |format|
        if @request.valid?
          product_service.save!
          @request = product_service.product
          set_flash_message
          format.html { redirect_to after_create_and_update_path }
        else
          format.html { render action: 'new' }
        end
      end
    end

    def update_request
      product_service = Services::Crud::Product.new(request_params, request_creator, params[:id])
      @request = product_service.product
      respond_to do |format|
        if @request.valid?
          product_service.save!
          @request = product_service.product
          set_flash_message
          format.html { redirect_to after_create_and_update_path }
        else
          edit_request
          format.html { render action: 'edit' }
        end
      end
    end

    def set_request
      @request = Product.where(id: params[:id]).first
    end

    def request_params
      params.require(:product)
      .permit(:id, :name, :description, :main_category,
        :user_id, :unit_price, :status_action, :start_date, :end_date,
        :status, :status_characteristic, :amount, { tag_list: []}
      )
    end

    def request_creator
      request_params[:user_id].blank? ? current_user : User.where(id: request_params[:user_id]).first
    end

    def set_flash_message
      flash[:notice] = 'Your request was successfully listed!!!'
    end
  end
end