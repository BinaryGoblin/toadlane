module Dashboard::FoldersHelper
  def importing_status(folder)
    if folder.error_message.present?
      folder.error_message
    elsif folder.import_status == 'completed'
      "#{folder.created_at.strftime('%m-%d-%Y')}<br/>#{folder.products.count} items".html_safe
    else
      folder.import_status
    end
  end
end
