# encoding: UTF-8
# rake task for create / drop Tax

namespace :db do
  desc 'populate db by Tax'
  task populate_db_tax: :environment do
    [ 0.0, 1.0, 2.0, 3.0 ].each do |data| 
      unless Tax.find_by_value(data)
        tax = Tax.new(
          value: data
        )
        tax.save!
        puts "---> added tax #{data}"
      end
    end
  end

  desc 'truncate Tax'
  task truncate_db_tax: :environment do
    Tax.delete_all
    puts '---> delete data from Tax'
  end
end

