# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  product_id         :integer
#  image_file_name    :string
#  image_file_size    :string
#  image_content_type :string
#  created_at         :datetime
#  updated_at         :datetime
#

class Image < ActiveRecord::Base
  belongs_to :product

  validates_presence_of :product_id, :image_file_name, :image_file_size, :image_content_type
  validates_numericality_of :product_id, only_integer: true

  has_attached_file :image, styles: {
                                small: '110x95#',
                                medium: '240x225#',
                                big: '620x420#'
                              },
                              default_url: '/images/products/:style/missing.png'
  do_not_validate_attachment_file_type :image
end
