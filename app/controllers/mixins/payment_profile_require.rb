module Mixins
  module PaymentProfileRequire

    def require_profile_for_order
      require_profile_completed
      require_minimum_order_quantity
      require_payment_profile
      require_verified_by_admin
    end

    def require_payment_profile
      get_product

      payment_profile_completed, error = case @product.default_payment
      when Product::PaymentOptions[:fly_buy]
        [current_user.fly_buy_profile_verified?, :no_fly_buy_profile]
      when Product::PaymentOptions[:same_day]
        [current_user.fly_buy_profile_verified?, :no_same_day_profile]
      when Product::PaymentOptions[:green]
        [current_user.green_profile_verified?, :no_green_profile]
      when Product::PaymentOptions[:amg]
        [current_user.amg_profile_verified?, :no_amg_profile]
      when Product::PaymentOptions[:emb]
        [current_user.emb_profile_verified?, :no_emb_profile]
      end

      return_to_path(error: error) unless payment_profile_completed
    end

    def require_profile_completed
      get_product

      return_to_path(error: :profile_not_completed) unless (current_user.company.present? && current_user.profile_complete?)
    end

    def require_minimum_order_quantity
      get_product

      return_to_path(error: :minimum_order_quantity) if params[:count].to_i < @product.minimum_order_quantity
    end

    def require_verified_by_admin
      get_product

      return_to_path(error: :unverified_by_admin) if (@product.default_payment_flybuy? || @product.default_payment_same_day?) && !current_user.fly_buy_verified_by_admin?
    end

    private

    def return_to_path(error:)
      return redirect_to dashboard_offer_path(@product, error: error) if @product.offer_for_request?

      return redirect_to product_path(@product, error: error)
    end

    def get_product
      @product ||= Product.find(params[:product_id])
    end
  end
end