require 'zip'
require 'fileutils'

# This is a simple example which uses rubyzip to
# recursively generate a zip file from the contents of
# a specified directory. The directory itself is not
# included in the archive, rather just its contents.
#
# Usage:
#   directory_to_zip = "/tmp/input"
#   output_file = "/tmp/out.zip"
#   zf = ZipFileGenerator.new(directory_to_zip, output_file)
#   zf.write()


class PreparationForZipFileGenerator

  attr_accessor :root_dir_to_zip, :out_zip_file, :output_file_name, :attachments_list

  def set_defaults
    @file_timestamp = Time.now.strftime("%Y%m%d%H%M%6N")
    @root_dir_to_zip = Rails.root.join('tmp', 'zipownia', "#{@file_timestamp}").to_s
    @prefix_output_file_name ||= "file_"
    @output_file_name ||= "#{@prefix_output_file_name}#{@file_timestamp}.zip"
    @out_zip_file ||= Rails.root.join('tmp', 'zipownia').to_s + "/#{@output_file_name}"
    @attachments_list ||= []
    FileUtils.mkdir_p @root_dir_to_zip unless File.exists?(@root_dir_to_zip)
  end

  def initialize(model_name, model_attribute_name, prefix_output_file_name, attachments_array)
    @model_name = model_name 
    @model_attribute_name = model_attribute_name
    @prefix_output_file_name = prefix_output_file_name 
    @attachments_list = attachments_array
    set_defaults
  end

  def copy_files_to_tmp(attachments_array=@attachments_list)
    attachments_array.each do |rec_id|
      #attachment = Attachment.find(rec_id)
      attachment = "#{@model_name}".constantize.find(rec_id)
      attachment_ancestors_names = attachment.ancestors.map(&:name)
      dest_path = attachment_ancestors_names.blank? ? "#{@root_dir_to_zip}" : "#{@root_dir_to_zip}/#{attachment_ancestors_names.reverse.join('/')}"
      FileUtils.mkdir_p dest_path unless File.exists?(dest_path)
      if attachment.is_file?
        #source_file_name_with_path = attachment.attached_file.file.file   
        #source_file_name_with_path = attachment.component_file.file.file   
        source_file_name_with_path = attachment.instance_eval("#{@model_attribute_name}").file.file   
        dest_file_name_with_path = "#{dest_path}/#{attachment.name}"
        FileUtils.cp(source_file_name_with_path, dest_file_name_with_path)  unless File.exists?(dest_file_name_with_path)
      else
        #puts "create directory for rec_id: #{attachment.id}"
        dest_directory_name_with_path = "#{dest_path}/#{attachment.name}"
        FileUtils.mkdir_p dest_directory_name_with_path unless File.exists?(dest_directory_name_with_path)
        copy_files_to_tmp(attachment.child_ids)
      end
    end
    
  end


  def delete_tmp_directory
    FileUtils.rm_r @root_dir_to_zip, :force => true
    #FileUtils.rmdir @root_dir_to_zip    
  end

end

class ZipFileGenerator
  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input_dir, output_file)
    @input_dir = input_dir
    @output_file = output_file
  end

  # Zip the input directory.
  def write
    entries = Dir.entries(@input_dir) - %w[. ..]

    ::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
      write_entries entries, '', zipfile
    end
  end

  private

  # A helper method to make the recursion work.
  def write_entries(entries, path, zipfile)
    entries.each do |e|
      zipfile_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zipfile_path)

      if File.directory? disk_file_path
        recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
      else
        put_into_archive(disk_file_path, zipfile, zipfile_path)
      end
    end
  end

  def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
    zipfile.mkdir zipfile_path
    subdir = Dir.entries(disk_file_path) - %w[. ..]
    write_entries subdir, zipfile_path, zipfile
  end

  def put_into_archive(disk_file_path, zipfile, zipfile_path)
    zipfile.add(zipfile_path, disk_file_path)
  end
end