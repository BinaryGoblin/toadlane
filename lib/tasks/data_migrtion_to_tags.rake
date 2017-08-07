namespace :data_migration do
  desc 'Migrate i buy and sell to user tags'
  task migrate_i_buy_and_sell_to_tags: :environment do
    Rails.logger.info '************** Migrate i buy and sell to user tags **************'
    begin
      User.all.each do |user|
        user.tag_list.add(user.benefits)
        user.save
        Rails.logger.info "Benefits:: #{user.benefits} ==>  User Tags:: #{user.tag_list}"
        puts "Benefits:: #{user.benefits} ==>  Tags:: #{user.tag_list}"
      end
    rescue => e
      Rails.logger.info e.inspect
    end
    Rails.logger.info '**************___________________________**************'
  end

  desc 'Migrate product subcategories to product tags'
  task migrate_product_subcategories_to_tags: :environment do
    Rails.logger.info '************** Migrate product sub categories to product tags **************'
    begin
      Product.all.each do |product|
        sub_categories = product.categories.where.not(name: 'all').map(&:name)
        if sub_categories.present?
          Rails.logger.info "Product:: #{product.name}"
          Rails.logger.info "Sub Categories:: #{sub_categories.inspect}"

          product.tag_list.add(sub_categories)
          product.save(validate: false)
        end
      end
    rescue => e
      Rails.logger.info e.inspect
    end
    Rails.logger.info '**************___________________________**************'
  end

  desc 'Replace tag id with proper tag name'
  task replace_tag_id_with_tag_name: :environment do
    puts '************** Process start: Replace tag id with proper tag name **************'
    begin
      Product.all.each do |product|
        if product.tag_list.present?
          product.tag_list.each do |tag|
            value = tag.to_i
            unless value.zero?
              puts "For product id: #{product.id}"
              tag_name = ActsAsTaggableOn::Tag.find(value).name
              product.tag_list.add(tag_name)
              product.tag_list.remove(tag)
            end
          end
          product.save
        end
      end
    rescue => e
      puts "Error: #{e.inspect}"
    end
    puts '**************___________________________**************'
  end
end