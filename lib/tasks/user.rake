# encoding: UTF-8
# rake task for create / drop Users

namespace :db do
  desc 'populate db by User'
  task populate_db_user: :environment do
    role = Role.find_by_name('user')
    (1..5).each do |data|
      unless User.find_by_email("user#{data}@example.com")
        user = User.new(
          email:                 "user#{data}@example.com",
          password:              '12345678',
		      terms_of_service:      true,
          name:                  "user user#{data}",
          tag_list:              "electronics, clothes"
        )
        user.skip_confirmation!
    		user.save!
        user.add_role role.name
        puts "---> added user #{user.email}"
      end
    end
  end

  desc 'truncate User'
  task truncate_db_user: :environment do
#    User.delete_all
    User.all.each do |user|
      user.destroy if user.has_role? :user
    end
    puts '---> delete data from User'
  end
end

