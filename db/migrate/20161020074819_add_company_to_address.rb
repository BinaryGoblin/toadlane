class AddCompanyToAddress < ActiveRecord::Migration
  def change
  	add_column :addresses, :of_company, :boolean, default: false
  end
end
