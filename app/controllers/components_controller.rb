require 'zip_file_generator'

class ComponentsController < ApplicationController
  before_action :authenticate_user!, except: [:download_simple]
  after_action :verify_authorized, only: [:show, :create, :destroy]
  before_action :set_component, only: [:show, :edit, :update, :destroy, :send_link_to_component_download, :send_link_to_component_download_simple]
  before_action :set_component_maybe_wrong, only: [:download]
  before_action :set_component_maybe_wrong_for_download_simple, only: [:download_simple]

  def datatables_index
#    component_parent_filter = params[:component_parent_id].present? ? params[:component_parent_id] : nil
    respond_to do |format|
      format.json{ render json: ComponentDatatable.new(params, view_context: view_context, 
        componentable_id: params[:componentable_id], 
        componentable_type: params[:componentable_type],
        component_parent_filter: params[:component_parent_id] ) }
    end
  end

  def download
    unless @component.present?
      flash[:error] = t('errors.messages.not_found_resource')
      skip_authorization
      redirect_to root_path()
    else
      component_authorize(@component, "download", @component.componentable_type.singularize.downcase)
      @component.log_work('download_component', current_user.id)

      respond_to do |format|
        format.html { 
          send_file "#{@component.component_file.path}", 
            type: "#{@component.file_content_type}",
            filename: @component.component_file.file.filename, 
            dispostion: "inline", 
            status: 200, 
            stream: true, 
            x_sendfile: true 
        }

        format.js { 
          # @file_url_as_html = "/#{params[:controller]}/#{params[:id]}/#{params[:action]}.html"
          @file_url_as_html = url_for( controller: params[:controller],
                                      action: params[:action],
                                      id:  params[:id],
                                      format: 'html',
                                      only_path: true)
          render 'download' 
        }
      end
    end
  end

  def download_simple
    unless @component.present?
      flash[:error] = t('errors.messages.not_found_resource')
      redirect_to root_path()
    else
      if @component.componentable.is_expired?
        flash[:error] = t('errors.messages.not_found_resource')
        redirect_to root_path()
      else
        # @component.log_work('download_component', current_user.id)

        respond_to do |format|
          format.html { 
            send_file "#{@component.component_file.path}", 
              type: "#{@component.file_content_type}",
              filename: @component.component_file.file.filename, 
              dispostion: "inline", 
              status: 200, 
              stream: true, 
              x_sendfile: true 
          }

        end
      end
    end
  end

  def zip_and_download
    @component_first_from_list = Component.find(params[:component_ids].first) unless params[:component_ids].empty?
    component_authorize(@component_first_from_list, "zip_and_download", @component_first_from_list.componentable_type.singularize.downcase)
    # if component_policy_check(@component_first_from_list, "zip_and_download", params[:controller].classify.deconstantize.singularize.downcase)

    respond_to do |format|
      format.zip {  
        component_ids = params[:component_ids].present? ? params[:component_ids] : []
 
        # create directory and copy file
        pr = PreparationForZipFileGenerator.new('Component', 'component_file', 'file', component_ids)
        pr.copy_files_to_tmp
        # ziped directory
        zf = ZipFileGenerator.new(pr.root_dir_to_zip, pr.out_zip_file)
        zf.write()
        # remove tmp folder
        pr.delete_tmp_directory

        component_ids.each do |id|
          component = Component.find(id)
          component.log_work('download_component', current_user.id)
        end

        send_file "#{pr.out_zip_file}", 
          filename: "#{pr.output_file_name}", 
          dispostion: "inline", 
          status: 200, 
          stream: true, 
          x_sendfile: true
      }
      format.js { 
        @file_url_as_zip = url_for( controller: params[:controller],
                                    action: params[:action],
                                    component_ids:  params[:component_ids],
                                    format: 'zip',
                                    only_path: true)
        @message = I18n.t('success.messages.wait_zip_created')
        render 'zip_and_download' 
      }
    end
  end

  def show
    component_authorize(@component, "show", @component.componentable_type.singularize.downcase)

    respond_to do |format|
      format.html {redirect_to @component.componentable }
      format.js { 
        @file_url_as_html = url_for( controller: params[:controller],
                                    action: :download,
                                    id:  @component.id,
                                    format: 'html',
                                    only_path: false)


        @file_url_as_html_to_simple = url_for( controller: params[:controller],
                                    action: :download_simple,
                                    id:  @component.for_simple_download,
                                    format: 'html',
                                    only_path: false)


        render 'show' 
      }
    end
  end

  # # GET /components/1/edit
  # def edit
  #   component_authorize(@component, "edit", @component.componentable_type.singularize.downcase) 
  # end

  def edit
    component_authorize(@component, "edit", @component.componentable_type.singularize.downcase) 

    respond_to do |format|
      format.html
      format.js { render 'edit' }
    end
  end

  # POST /components
  # POST /components.json
  def create
    @component = params[:component].present? ? @componentable.components.new(component_params) : @componentable.components.new()
    component_authorize(@component, "create", params[:controller].classify.deconstantize.singularize.downcase)

    @component = @componentable.components.create(component_params)
    @component.log_work('upload_file', current_user.id) if @component.errors.empty?

    @message = I18n.t('activerecord.successfull.messages.downloaded', data: @component.fullname)
  end

  def create_folder
    @component = params[:component].present? ? @componentable.components.new(component_params_for_create_folder) : @componentable.components.new()

    if component_policy_check(@component, "create", params[:controller].classify.deconstantize.singularize.downcase)
      @component = @componentable.components.create(component_params_for_create_folder)
      @component.log_work('create_directory', current_user.id) if @component.errors.empty?

      respond_to do |format|
        format.js  { 
          @message = I18n.t('activerecord.successfull.messages.created', data: @component.fullname)
          render status: :created, layout: false, file: 'components/create_folder.js.erb' 
        }
      end
    else
      respond_to do |format|
        @status = "forbidden"
        format.js  { 
          render status: :forbidden, layout: false, file: 'components/create_folder.js.erb' 
        }
      end
    end
  end

  def update
    @component.author = current_user
    component_authorize(@component, "update", @component.componentable_type.singularize.downcase)

    respond_to do |format|
      if @component.update(component_update_params)
        @component.log_work('update_component', current_user.id)
        format.html { 
          flash[:success] = t('activerecord.successfull.messages.updated', data: @component.fullname)
          redirect_to url_for(only_path: true, controller: @component.componentable_type.pluralize.downcase, action: 'show', id: @component.componentable.id) 
        }
        format.js { 
          @message = I18n.t('activerecord.successfull.messages.updated', data: @component.fullname)
          render 'update' 
        }
      else
        format.html { render :edit }
        format.js { render 'edit' }
      end
    end
  end

  def destroy
    component_authorize(@component, "destroy", @component.componentable_type.singularize.downcase)
    if @component.destroy_and_log_work(current_user.id)
      @message = I18n.t('activerecord.successfull.messages.destroyed', data: @component.fullname)
      render 'destroy' 
    else
      @message = I18n.t('activerecord.errors.messages.destroyed', data: @component.fullname)
      render 'destroy_error' 
    end

  end

  def move_to_parent
    @component_first_from_list = Component.find(params[:children_ids].first) unless params[:children_ids].empty?
    component_authorize(@component_first_from_list, "move_to_parent", @component_first_from_list.componentable_type.singularize.downcase)
    # if component_policy_check(@component_first_from_list, "zip_and_download", params[:controller].classify.deconstantize.singularize.downcase)

    errors = Component::move_to_parent_and_log_work(params[:parent_id], params[:children_ids], current_user.id)

    if errors.blank?
      # head :ok
      @message = I18n.t('activerecord.successfull.messages.moved')
      render 'move_to_parent'
    else
      errors_msgs = ""    

      errors.each do |msg|
        errors_msgs += msg.full_messages.join(', ').force_encoding("UTF-8")
      end

      render status: :conflict, json: { "errors": "#{errors_msgs}" }

      # respond_to do |format|
      #   # that will mean to send a javascript code to client-side;
      #   format.js { render             
      #       # raw javascript to be executed on client-side
      #       "alert('Hello Rails');", 
      #       # send HTTP response code on header
      #       :status => 404, # page not found
      #       # load /app/views/your-controller/different_action.js.erb
      #       :action => "different_action",
      #       # send json file with @line_item variable as json
      #       :json => { errors: "#{errors_msgs}" },
      #       :file => filename,
      #       :text => "#{errors_msgs}",
      #       # the :location option to set the HTTP Location header
      #       :location => path_to_controller_method_url(argument)
      #     }

      # end

    end 
  end

  def send_link_to_component_download
    component_authorize(@component, "send_link_to_component_download", @component.componentable_type.singularize.downcase)

    if params[:users_ids].blank?
      respond_to do |format|
        format.js { render :blank_users_ids }
      end
    else
      params[:users_ids].each do |i|
        user = User.find(i)
        CloudMailer.link_component_download(@component, user, current_user).deliver_later
      end
      respond_to do |format|
        format.js
      end
    end
  end

  def send_link_to_component_download_simple
    component_authorize(@component, "send_link_to_component_download_simple", @component.componentable_type.singularize.downcase)

    if params[:user].present?
      user_id = params[:user].fetch(:id, '').present? ? params.fetch(:user, '').fetch(:id, '') : nil
    else 
      user_id = nil
    end

    if params[:users_ids].blank? && user_id.blank?
      respond_to do |format|
        format.js { render :blank_users_ids }
      end
    else      
      params[:users_ids].each do |i|
        user = User.find(i)
        CloudMailer.link_component_download_simple(@component, user, current_user).deliver_later
      end unless params[:users_ids].blank?
      unless user_id.blank?
        user = User.find(user_id)
        CloudMailer.link_component_download_simple(@component, user, current_user).deliver_later
      end
      respond_to do |format|
        format.js
      end
    end
  end


  private
    def component_authorize(model_class, action, sub_controller)
      unless ['index', 'show', 'create', 'edit', 'update', 'destroy', 'zip_and_download', "move_to_parent", 'download', 
              'send_link_to_component_download', 'send_link_to_component_download_simple'].include?(action)
         raise "Ruby injection"
      end
      authorize model_class,"#{sub_controller}_#{action}?"      
    end

    def component_policy_check(model_class, action, sub_controller)
      unless ['index', 'show', 'create', 'edit', 'update', 'destroy', 'zip_and_download', "move_to_parent", 'download', 
              'send_link_to_component_download', 'send_link_to_component_download_simple'].include?(action)
         raise "Ruby injection"
      end
      return policy(model_class).send("#{sub_controller}_#{action}?")      
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_component
      @component = Component.find(params[:id])
    end

    def set_component_maybe_wrong
      @component = Component.find_by(id: params[:id])
    end

    def set_component_maybe_wrong_for_download_simple
      @component = Component.find_by(for_simple_download: params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def component_params
      defaults = { author_id: "#{current_user.id}" }
      params.require(:component).permit(:componentable_id, :componentable_type, :component_file, :note, :author_id, :parent_id ).reverse_merge(defaults)
    end

    def component_params_for_create_folder
      defaults = { author_id: "#{current_user.id}" }
      params.require(:component).permit(:componentable_id, :componentable_type, :name_if_folder, :note, :author_id, :parent_id ).reverse_merge(defaults)
    end

    def component_update_params
      defaults = { author_id: "#{current_user.id}" }
      params.require(:component).permit(:name_if_folder, :note, :author_id, :parent_id).reverse_merge(defaults)
    end
end
