class Dashboards::InvoicesController < ::DashboardsController
  def index
    @invoices = ArmorInvoice.where(deleted: false).own_invoices(current_user.id).order('created_at DESC').paginate(page: params[:page], per_page: params[:count])
  end

  def delete_cascade
    if params[:invoices_ids].present?
      params[:invoices_ids].each do |id|
        ArmorInvoice.find(id).update(deleted: true)
      end
    end

    render json: :ok
  end
end
