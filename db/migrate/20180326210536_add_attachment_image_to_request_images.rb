class AddAttachmentImageToRequestImages < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      create table request_images (
        id serial primary key,
        request_id integer references requests,
	create_at timestamp,
	updated_at timestamp
      );
    SQL

    change_table :request_images do |t|
      t.attachment :image
    end
  end

  def self.down
    execute <<-SQL
      drop table request_images;
    SQL
  end
end
