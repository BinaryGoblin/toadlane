module Services
  module Notifications
    class AdditionalSellerNotification
      attr_reader :group_sellers, :product, :current_user

      def initialize(group_sellers, product, current_user)
        @group_sellers = group_sellers
        @product = product
        @current_user = current_user
      end

      def send
        group_sellers.each do |group_seller|
          user = group_seller.user
          UserMailer.send_added_as_additional_seller_notification(current_user, user, product, group_seller).deliver_later
          group_seller.update_attributes(notified: true)
        end
      end
    end
  end
end