module Services
  module ActivityTracker
    module ConfigData
      TASK_LIST = {
        updating_profile:               { positive: 1, negative: 0, description: '<b>%{u}</b> updated their profile.' },
        creating_product_with_asset:    { positive: 2, negative: 0, description: '<b>%{u}</b> listed <b>%{p}</b> for sale!' },
        creating_product_without_asset: { positive: 1, negative: 0, description: '<b>%{u}</b> listed <b>%{p}</b> for sale!' },
        creating_seller_group:          { positive: 2, negative: 0, description: '<b>%{g}</b> group created for <b>%{p}</b> for sale!' },
        adding_stripe_account:          { positive: 1, negative: 0, description: '<b>%{u}</b> is now accepting stripe payments.' },
        adding_green_profile_account:   { positive: 1, negative: 0, description: '<b>%{u}</b> is now accepting green by phone payments.' },
        adding_amg_profile_account:     { positive: 1, negative: 0, description: '<b>%{u}</b> is now accepting advanced merchant group payments.' },
        adding_emb_profile_account:     { positive: 1, negative: 0, description: '<b>%{u}</b> is now accepting e merchant broker payments.' },
        adding_fly_and_buy_account:     { positive: 2, negative: 0, description: '<b>%{u}</b> is now accepting fly and buy payments.' },
        placing_order:                  { positive: 2, negative: 0, description: 'An order for <b>%{p}</b> has just been placed! There are %{q} units left. %{link}' },
        fund_release:                   { positive: 3, negative: 0, description: '<b>%{u}</b> just succesfully sold <b>%{p}</b>! %{link}' },
        not_sending_funds_into_escrow:  { positive: 0, negative: 3 },
        invite_users_outside_toadlane:  { positive: 1, negative: 0 }
      }
    end
  end
end