class AddNewRequestedDateToInspectionDates < ActiveRecord::Migration
  def change
    add_column :inspection_dates, :new_requested_date, :datetime, default: nil
  end
end
