#require 'mime/types'
require 'my_human'

class ComponentUploader < CarrierWave::Uploader::Base
  include ActionView::Helpers::NumberHelper
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    # "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    # OK!
    #{}"/home/bjarzab/www/inwentaryzacja_storage/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    # OK!
    # "/mnt/cloud_test/files/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    "#{Rails.application.secrets[:carrierwave_store_dir]}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # zdefinowac w pliku secrets
  def cache_dir
    # should return path to cache dir
    # OK!
    #{}"/home/bjarzab/www/inwentaryzacja_storage/tmp"
    # OK! 
    # "/mnt/cloud_test/files/tmp"
    "#{Rails.application.secrets[:carrierwave_cache_dir]}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # # Add a white list of extensions which are allowed to be uploaded.
  # # For images you might use something like this:
  # def extension_whitelist
  #  %w(zip z00 z01 z02 z03 z04 z05 z06 z07 z08 z09 rar r00 r01 r02 r03 r04 r05 r06 r07 r08 r09 7z csv csv geojason gml xsd gpkg kml shx shp prj dbf cpg)
  # end

  # def extension_allowlist
  #  %w(zip z00 z01 z02 z03 z04 z05 z06 z07 z08 z09 rar r00 r01 r02 r03 r04 r05 r06 r07 r08 r09 7z csv csv geojason gml xsd gpkg kml shx shp prj dbf cpg)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  process :override_content_type_and_save_info

  def override_content_type_and_save_info
#    file.content_type = MIME::Types.type_for(original_filename).first.to_s
    case File.extname(file.file).delete('.').downcase.to_sym.to_s
    when 'xlsx'
      file.content_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    when 'docx'
      file.content_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    when 'pptx'
      file.content_type = 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
    when 'rar'
      file.content_type = 'application/vnd.rar'
    when 'zip'
      file.content_type = 'application/zip'
    when '7z'
      file.content_type = 'application/x-7z-compressed'
    when 'bat'
      file.content_type = 'application/x-msdos-program'
    when 'cmd'
      file.content_type = 'application/cmd'
    when 'exe'
      file.content_type = 'application/x-msdownload'
    when 'msi'
      file.content_type = 'application/x-msi'
    when 'php'
      file.content_type = 'application/x-php'
    when 'py'
      file.content_type = 'application/x-python'
    when 'vbs'
      file.content_type = 'application/x-vbs'
    when 'csv'
      file.content_type = 'text/csv'
    end

    # Add in model on init  
    model.file_content_type = file.content_type if file.content_type
    # model.file_size = number_to_human_size(file.size, options = {}) if file.size
    model.file_size = MyHuman.new.filesize(file.size) if file.size
  end

end
