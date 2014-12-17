class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.id
      case user.role.name
      when 'superadmin'
        can :manage, :all
      when 'admin'
        can :create, User
        can :create, Product     
      when 'user'
        can :read, User, id: user.id
        can [:update, :manage], User, id: user.id
        can :create, Product
        can [:update, :manage], Product, user_id: user.id
      end
    end
  end
end
