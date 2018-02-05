class AddFeeToGroupSellers < ActiveRecord::Migration
  def change
    add_column :group_sellers, :fee, :decimal
  end
end
