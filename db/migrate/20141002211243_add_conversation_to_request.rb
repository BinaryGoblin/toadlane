class AddConversationToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :conversation, :integer
  end
end
