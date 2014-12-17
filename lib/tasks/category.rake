# encoding: UTF-8
# rake task for create / drop Category

namespace :db do
  desc 'populate db by Category'
  task populate_db_category: :environment do
    ['electronics', 'clothes', 'shoes', 'toys' ].each do |data| 
      unless Category.find_by_name(data)
        category = Category.new(
          name: data
        )
        category.save!
        puts "---> added category #{data}"
      end
    end

    ['iphone', 'mac'].each do |data|
      main = Category.find_by_name('electronics')

      unless Category.find_by_name(data)
        subcategory = Category.new(
          name: data, 
          parent_id: main.id
        )
        subcategory.save!
        puts "---> added subcategory #{data}"
      end      
    end
  end

  desc 'truncate Category'
  task truncate_db_category: :environment do
    Category.delete_all
    puts '---> delete data from Category'
  end
end

