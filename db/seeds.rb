# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


["superadmin", "admin", "user", "seller", "group admin"].each do |role|
	unless Role.find_by_name(role)
	  Role.create(name: role)
	end
end
