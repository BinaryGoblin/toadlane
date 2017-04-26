class HtmlRenderer < ActionController::Metal
  include ActionView::ViewPaths
  include AbstractController::Rendering
  include AbstractController::Helpers
  include ActionController::Helpers
  include ActionView::Rendering
  include ActionView::Layouts
  include ActionController::Rendering
  include ActionController::Renderers
  include ActionController::Renderers::All
  include InspectionServiceHelper

  append_view_path 'app/views'

  helper_method :inspected_items_count

  View = Struct.new(:partial, :locals)

  def render_html(view)
    html = render_to_string(
      partial: view.partial,
      locals: view.locals
    )

    kit = IMGKit.new(html)
    file  = Tempfile.new(['invoice', '.png'], encoding: 'ascii-8bit')
    file.write(kit.to_png)

    file
  end
end
