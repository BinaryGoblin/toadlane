class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.string :filename
      t.string :content_type
      t.binary :data
      t.references :user, index: true

      t.timestamps
    end
  end
end
