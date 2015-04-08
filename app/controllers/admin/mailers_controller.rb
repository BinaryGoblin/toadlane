class Admin::MailersController < Admin::ApplicationController
  layout 'admin_dashboard'

  def index
    @users = Role.find_by(name: :user).users.where(receive_new_offer: true).order('id ASC')
    @products = Product.all.order('updated_at DESC')
  end

  def services
    products = Product.where(id: mailer_params[:products_ids])
    users = User.where(id: mailer_params[:users_ids], receive_new_offer: true)

    if users.any? && products.any?
      users.each do |user|
        ServiceMailer.send_new_service_info(user, products).deliver
      end
    end

    redirect_to admin_mailers_path, notice: 'Sended.'
  end

  private
    def mailer_params
      params.require(:mailer).permit(products_ids: [], users_ids: [])
    end
end
