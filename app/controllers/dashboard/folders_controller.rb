class Dashboard::FoldersController < DashboardController

  def index
    @folders = current_user.folders.includes(:products).paginate(page: params[:page], per_page: params[:count]).order('id DESC')
  end

  def new
    @folder = current_user.folders.build
  end

  def create
    @folder = current_user.folders.build(folder_params.merge!(import_status: 'running'))
    @folder.save!
    Importers::Product.perform_later(@folder, current_user)

    flash[:notice] = "Thank you for your patience as we import your products."
    redirect_to dashboard_folders_path
  end

  def edit
    @folder = Folder.importing_completed.where(id: params[:id]).first
    @products = @folder.products.paginate(page: params[:page], per_page: params[:count]).order('id DESC')
  end

  def show
    folder = Folder.importing_completed.where(id: params[:id]).first
    @products = folder.products.paginate(page: params[:page], per_page: params[:count]).order('id DESC')
  end

  def destroy
    @folder = current_user.folders.where(id: params[:id]).first
    @folder.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_folders_path }
    end
  end

  private

  def folder_params
    params.require(:folder)
      .permit(:name, :import, :import_status)
  end
end
