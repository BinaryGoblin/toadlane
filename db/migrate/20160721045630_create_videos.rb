class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer :product_id
      t.string :video_file_name
      t.string :video_file_size
      t.string :video_content_type

      t.timestamps null: false
    end
  end
end
