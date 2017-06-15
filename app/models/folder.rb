# == Schema Information
#
# Table name: folders
#
#  id                    :integer          not null, primary key
#  import_file_name      :string
#  import_content_type   :string
#  import_file_size      :string
#  import_updated_at     :date
#  user_id               :integer
#  import_status         :string
#  error_message         :string
#
class Folder < ActiveRecord::Base
  has_attached_file :import
  validates_attachment_content_type :import, content_type: /\Aapplication\/.*\z/

  belongs_to :user
  has_many :products, dependent: :destroy

  scope :importing_completed, -> { where(import_status: 'completed') }
end
