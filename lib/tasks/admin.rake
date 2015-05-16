# encoding: UTF-8
# rake task for create / drop Users

namespace :db do
  desc 'populate db by User/Admin'
  task populate_db_admin: :environment do
    role = Role.find_by_name('admin')
    (1..5).each do |data|
      unless User.find_by_email("admin#{data}@example.com")
        user = User.new(
          email:                 "admin#{data}@example.com",
          password:              '12345678',
          password_confirmation: '12345678'
        )
        user.skip_confirmation!
        user.save

        user.add_role role.name
        puts "---> added user #{user.email}"
      end
    end
  end

  desc 'truncate User'
  task truncate_db_admin: :environment do
    User.all.each do |user|
      user.destroy if user.has_role? :admin
    end
    puts '---> delete data from User'
  end

  desc 'Migrate status_characteristic to type'
  task 'product:status_characteristic_to_type': :environment do
    Product.all.each do |product|
      begin
        type = if product.status_characteristic =~ /buy/i then 1 else 0 end
        product.update_column(:type, type)
        puts "\##{product.id}: \"#{product.name}\" now listed as #{product.type}"
      rescue => e
        puts "Error: #{e.message}"
        puts "Product #: #{product.id}, \"#{product.name}\" not updated"
      end
    end
  end

  desc 'Convert ArmorOrder seller/buyer ids to reference user Primary Keys'
  task 'armor_order:fix_ids': :environment do
    ArmorOrder.all.each do |order|
      begin
        order.seller_id = User.find_by(armor_user_id: order.seller_id).id
        order.buyer_id = User.find_by(armor_user_id: order.buyer_id).id
        order.save
        puts "ArmorOrder #: #{order.id} updated"
      rescue => e
        puts "Error: #{e.message}"
        puts "ArmorOrder ##{order.id}, sold to #{order.buyer_id} by #{order.seller_id} not updated"
      end
    end
  end
end

