module Importers
  class ImportFileMissingError < StandardError; end
  class InvalidFileExtensionError < StandardError; end

  class FileCreator
    BASE_PATH = Rails.root
    VALID_EXT = [".xls", ".xlsx", ".ods", ".csv"]

    def initialize(import_file, dir_name)
      @import_file = import_file
      @dir_name = dir_name
    end

    def create!
      validate_params!

      create_dir_if_not_exist
      remove_all_files

      File.open(file_path, "w") do |file|
        file.write File.read(import_file.tempfile.path)
      end

      file_path
    end

    private

    def validate_params!
      raise Importers::ImportFileMissingError, "Missing import file." unless import_file.present?
      raise Importers::InvalidFileExtensionError, "You can only upload files having extensions #{VALID_EXT.join(', ')}." unless VALID_EXT.include?(extname)
    end

    def extname
      File.extname(import_file.original_filename)
    end

    def folder_path
      File.join(BASE_PATH, dir_name)
    end

    def file_path
      File.join(folder_path, import_file.original_filename)
    end

    def remove_all_files
      FileUtils.rm_rf("#{folder_path}/.", :secure => true)
    end

    def create_dir_if_not_exist
      FileUtils.mkdir_p(folder_path)
    end

    attr_reader :import_file, :dir_name
  end
end