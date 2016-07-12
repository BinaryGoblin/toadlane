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

FactoryGirl.define do
  factory :image do
    image_file_name 'image name'
    image_file_size '32000'
    image_content_type 'jpeg'
    association :product
  end
end
