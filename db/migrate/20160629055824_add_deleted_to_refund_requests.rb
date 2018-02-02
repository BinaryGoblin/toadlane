class AddDeletedToRefundRequests < ActiveRecord::Migration
  def change
    add_column :refund_requests, :deleted, :boolean, default: false
  end
end
