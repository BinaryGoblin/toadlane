module Mixins
  module OfferHelper
    private

    def new_offer
      if params[:product].present?
        @offer = Product.new(offer_params)
      else
        @offer = Product.new
      end
      build_related_models
    end

    def edit_offer
      build_related_models
      @history = PaperTrail::Version.where(item_id: @offer.id).order('created_at DESC')
    end

    def create_offer
      params[:product].merge!(start_date: DateTime.now, request_id: @request.id)

      product_service = Services::Crud::Product.new(offer_params, offer_creator)
      @offer = product_service.product
      respond_to do |format|
        if @offer.valid?
          product_service.save!
          @offer = product_service.product
          notify_request_owner
          set_flash_message
          format.html { redirect_to after_create_and_update_path }
        else
          build_related_models
          format.html { render action: 'new' }
        end
      end
    end

    def update_offer
      product_service = Services::Crud::Product.new(offer_params, offer_creator, params[:id])
      @offer = product_service.product
      respond_to do |format|
        if @offer.valid?
          product_service.save!
          @offer = product_service.product
          set_flash_message
          format.html { redirect_to after_create_and_update_path }
        else
          edit_offer
          format.html { render action: 'edit' }
        end
      end
    end

    def set_offer
      @offer = Product.where(id: params[:id]).first
      @request = @offer.request
    end

    def offer_params
      params.require(:product)
      .permit(:id, :name, :negotiable, :description,
        :user_id, :unit_price, :status_action,
        :status, :status_characteristic, :request_id,
        :start_date, :end_date, :amount,
        :dimension_width, :dimension_height, :dimension_depth,
        :dimension_weight, :default_payment,
        :shipping_estimates_attributes => [ :id, :cost, :description, :product_id, :_destroy, :type ],
        images_attributes: [:id, :image, :product_id, :_destroy],
        :videos_attributes => [:id, :video, :product_id, :_destroy], :videos_attributes_delete => [],
        :inspection_dates_attributes => [:id, :date, :product_id, :_destroy],
      )
    end

    def offer_creator
      offer_params[:user_id].blank? ? current_user : User.where(id: offer_params[:user_id]).first
    end

    def build_related_models
      @offer.inspection_dates.build if @offer.inspection_dates.blank?
      @offer.shipping_estimates.build if @offer.shipping_estimates.blank?
    end

    def set_flash_message
      if !@offer.active_product? && !@offer.owner_default_payment_verified?
        flash[:error] = 'Your offer is not active, since your payment profile is not complete.'
      else
        flash[:notice] = 'Your offer was successfully listed!!!'
      end
    end

    def notify_request_owner
      NotificationMailer.offer_notification_email(@offer, @request).deliver_later
    end
  end
end