# == Schema Information
#
# Table name: certificates
#
#  id           :integer          not null, primary key
#  filename     :string
#  content_type :string
#  data         :binary
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Certificate < ActiveRecord::Base
  belongs_to :user
  belongs_to :product

  def filename=(new_filename)
    write_attribute("filename", sanitize_filename(new_filename))
  end

  def uploaded_file=(incoming_file)
    self.filename = incoming_file.original_filename
    self.content_type = incoming_file.content_type
    self.data = incoming_file.read
  end

  private
    def sanitize_filename(filename)
      just_filename = File.basename(filename)
      just_filename.gsub(/[^\w\.\-]/, '_')
    end
end
