class AddTermsOfServiceToUser < ActiveRecord::Migration
  def change
    add_column :users, :terms_of_service, :boolean
    add_column :users, :terms_accepted_at, :datetime
  end
end