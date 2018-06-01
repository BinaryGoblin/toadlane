module RequestHelper
  def setup_request(product)
    product.request ||= Request.new
    product.request.request_images.build
    product
  end
end