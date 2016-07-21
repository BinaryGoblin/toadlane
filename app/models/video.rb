# == Schema Information
#
# Table name: videos
#
#  id                 :integer          not null, primary key
#  product_id         :integer
#  video_file_name    :string
#  video_file_size    :string
#  video_content_type :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Video < ActiveRecord::Base
  belongs_to :product

  validates_presence_of :product_id, :video_file_name, :video_file_size, :video_content_type

  has_attached_file :video, styles: {
    medium: {
      geometry: '640x480',
      format: 'mp4'
    },
    small: { :geometry => "110x95#", :format => 'jpg'}
  }, :processors => [:transcoder]
  do_not_validate_attachment_file_type :video
end
