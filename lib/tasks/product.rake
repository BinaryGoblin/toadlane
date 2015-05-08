# encoding: UTF-8

namespace :db do
  desc 'populate db by Product'
  task populate_db_product: :environment do
#    category  = Category.

#    role = Role.find_by_name('user').id
#    find = []
#    users = User.all
#    users.each do |user|
#      find << user.roles.pluck(:id).include?(role)
#    end

    # TODO without array
    data_users = ["user1@example.com", "user2@example.com", "user3@example.com", "user4@example.com", "user5@example.com"]
    user = User.find_by_email(data_users.sample).id

    (1..10).each do |data|
      unless Product.unexpired.find_by(name: "Product No. #{data}")
        product = Product.new(
          name: "Product No. #{data}",
          description: 'description',
          start_date: Date.today - 1.day,
          end_date: Date.today + 5.day,
          main_category: Category.where(parent_id: nil).sample.id,
          unit_price: rand(5..20),
          amount: rand(15..170),
          user_id: user,
          status_action: ["active", "disabled", "futured", "recommended", "best"].sample,
          status_characteristic: ["sell", "buy"].sample
        )
        product.save!
        puts "---> added product #{product.name}"

        category = Category.all.sample
        product.categories << category
        puts "---> added product to category #{category.name}"
      end
    end
  end

  desc 'truncate Product'
  task truncate_db_product: :environment do
    Product.delete_all
    puts '---> delete data from Product'
  end

end

