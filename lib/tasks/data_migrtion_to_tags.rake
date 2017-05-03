namespace :data_migration do
  desc 'Migrate i buy and sell to user tags'
  task migrate_i_buy_and_sell_to_tags: :environment do
    Rails.logger.info '************** Migrate i buy and sell to user tags **************'
    begin
      User.all.each do |user|
        user.tag_list.add(user.benefits)
        Rails.logger.info "Benefits:: #{user.benefits} ==>  Tags:: #{user.tag_list}"
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
        sub_categories = product.categories.collect{ |p| p.name}.reject{|p| p == 'all'}
        product.tag_list.add(sub_categories)
        Rails.logger.info "Benefits:: #{sub_categories} ==>  Tags:: #{product.tag_list}"
      end
    rescue => e
      Rails.logger.info e.inspect
    end
    Rails.logger.info '**************___________________________**************'
  end
end