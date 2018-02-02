class Admin::Users::ManagementsController < Admin::UsersController
  before_action :set_user, only: [:promote, :demote, :activate, :deactivate]
  
  def index
    @users = User.paginate(page: params[:page], per_page: params[:count]).order('id ASC')
  end
  
  def promote
    respond_to do |format|
      if@user.has_role? :user
        if @user.has_role? :admin
          if @user.add_role :superadmin
            format.html { redirect_to admin_users_managements_path, notice: 'User promoted to super admin.' }
          else
            format.html { redirect_to admin_users_managements_path, notice: 'Error promoting user.' }
          end
        else
          if @user.add_role :admin
            format.html { redirect_to admin_users_managements_path, notice: 'User promoted to admin.' }
          else
            format.html { redirect_to admin_users_managements_path, notice: 'Error promoting user.' }
          end
        end
      else
        format.html { redirect_to admin_users_managements_path, notice: 'Cannot promote disactivated user.'}
      end
    end
  end
  
  def demote
    respond_to do |format|
      if @user.has_role? :superadmin
        if @user.revoke :superadmin
          format.html { redirect_to admin_users_managements_path, notice: 'User demoted to admin.' }
        else
          format.html { redirect_to admin_users_managements_path, notice: 'Error demoting user.' }
        end
      else
        if @user.revoke :admin
          format.html { redirect_to admin_users_managements_path, notice: 'User demoted to user.' }
        else
          format.html { redirect_to admin_users_managements_path, notice: 'Error demoting user.' }
        end
      end
    end    
  end
  
  def activate
    respond_to do |format|
      if @user.has_role? :user
        format.html { redirect_to admin_users_managements_path, notice: 'User already activated.' }
      else
        @user.add_role :user
        format.html { redirect_to admin_users_managements_path, notice: 'User activated.' }
      end
    end    
  end
  
  def deactivate
    respond_to do |format|
      @user.revoke :superadmin
      @user.revoke :admin
      if @user.revoke :user
        format.html { redirect_to admin_users_managements_path, notice: 'User deactivated.' }
      else
        format.html { redirect_to admin_users_managements_path, notice: 'User already deactivated.' }
      end
    end    
  end
  
  private
    def set_user
      @user = User.find(params[:id])
    end  
  
    def user_params
      params.require(:user)
    end
end