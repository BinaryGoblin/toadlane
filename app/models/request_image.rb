class RequestImage < ActiveRecord::Base
  belongs_to :request 

  validates_presence_of :image_file_name, :image_file_size, :image_content_type

  has_attached_file :image, styles: {
                                small: '110x95#',
                                medium: '240x225#',
                                big: '620x420#'
                              },
                              default_url: '/images/requests/:style/missing.png'
  do_not_validate_attachment_file_type :image
end
