class Ability
  include CanCan::Ability

  def initialize(user)
    if current_user
      case
      when current_user.has_role? 'superadmin'
        can :manage, :all
      when current_user.has_role? 'admin'
        can :create, User
        can :create, Product     
      when current_user.has_role? 'user'
        can :read, User, id: user.id
        can [:update, :manage], User, id: user.id
        can :create, Product
        can [:update, :manage], Product, user_id: user.id
      end
    end
  end
end
