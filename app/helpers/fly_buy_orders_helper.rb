module FlyBuyOrdersHelper

	def get_fly_buy_toadlane_fee
		Fee.find_by(:module_name => "Fly & Buy").value
	end
end
