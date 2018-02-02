# encoding: UTF-8
# rake task for create / drop Role

namespace :db do
  desc 'populate db by Role'
  task populate_db_role: :environment do
    ['superadmin', 'admin', 'user', 'quest'].each do |data|
      unless Role.find_by_name(data)
        role = Role.new(
          name: data
        )
        role.save!
        puts "---> added role #{data}"
      end
    end
  end

  desc 'truncate Role'
  task truncate_db_role: :environment do
    Role.delete_all
    puts '---> delete data from Role'
  end
end

