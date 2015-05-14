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
      type = if product.status_characteristic =~ /buy/i then 1 else 0 end
      product.update_column(:type, type)
      puts "\##{product.id}: \"#{product.name}\" now listed as #{product.type}"
    end
  end
end

