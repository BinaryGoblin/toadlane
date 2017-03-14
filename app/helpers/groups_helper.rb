module GroupsHelper

  def group_admin
    Role.find_by_name("group admin")
  end
end
