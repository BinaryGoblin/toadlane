class AddAmountToGreenChecks < ActiveRecord::Migration
  def change
    add_column :green_checks, :amount, :float
  end
end
