class AddBenefitsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :benefits, :text
  end
end
