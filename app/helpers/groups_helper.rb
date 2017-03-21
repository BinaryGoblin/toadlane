module GroupsHelper
  def is_current_user_authorized? group
    group_seller = group.group_sellers.where(user_id: current_user.id).first
    user_role = group_seller.is_group_admin? if group_seller.present?
    current_user == group.owner || user_role == true
  end

  def is_user_a_member?(user, group)
    if group.owner != user
      group.group_sellers.find_by_user_id(user.id).present?
    else
      false
    end
  end

  def find_group_member(user, group)
    group.group_sellers.where(user_id: user.id).first
  end

  def is_current_user_group_member? group, group_member
    group.product.owner == current_user || group_member.user == current_user
  end
end
