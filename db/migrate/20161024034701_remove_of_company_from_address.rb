class RemoveOfCompanyFromAddress < ActiveRecord::Migration
  def change
  	remove_column :addresses, :of_company
  end
end
