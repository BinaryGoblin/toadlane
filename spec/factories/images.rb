FactoryGirl.define do
  factory :image do
    image_file_name 'image name'
    image_file_size '32000'
    image_content_type 'jpeg'
    association :product
  end
end
