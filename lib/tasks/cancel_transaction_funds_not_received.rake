desc "After a day if funds not received in escrow"
task :cancel_transaction_funds_not_received => :environment do
	inspection_dates = InspectionDate.approved.with_order_id.where('inspection_dates.date BETWEEN ? AND ?',
				            	1.days.from_now.beginning_of_day,
				            	1.days.from_now.end_of_day
				            )

	inspection_dates.each do |inspection_date|
		fly_buy_order = FlyBuyOrder.find_by_id(inspection_date.fly_buy_order_id)
		if fly_buy_order.synapse_transaction_id.present? && fly_buy_order.funds_in_escrow == false
			client = FlyBuyService.get_client

	    seller_fly_buy_profile = fly_buy_order.seller.fly_buy_profile
	    buyer_fly_buy_profile = fly_buy_order.buyer.fly_buy_profile

	    user_response = client.users.get(user_id: FlyBuyProfile::AppUserId)

	    client_user = FlyBuyService.get_user(oauth_key: nil, fingerprint: FlyBuyProfile::AppFingerPrint, ip_address: current_user.fly_buy_profile.synapse_ip_address, user_id: FlyBuyProfile::AppUserId)

	    oauth_payload = {
	      "refresh_token" => user_response['refresh_token'],
	      "fingerprint" => FlyBuyProfile::AppFingerPrint
	    }

	    oauth_response = client_user.users.refresh(payload: oauth_payload)

	    client_user = FlyBuyService.get_user(oauth_key: oauth_response["oauth_key"], fingerprint: FlyBuyProfile::AppFingerPrint, ip_address: current_user.fly_buy_profile.synapse_ip_address, user_id: FlyBuyProfile::AppUserId)

	    cancel_transaction = client_user.trans.delete(
	                          node_id: buyer_fly_buy_profile.synapse_node_id,
	                          trans_id: fly_buy_order.synapse_transaction_id)
	    if cancel_transaction.present? && cancel_transaction["recent_status"]["status"] == "CANCELED"
	      fly_buy_order.update_attribute(:status, 'cancelled')
	    end
		end
	end
end