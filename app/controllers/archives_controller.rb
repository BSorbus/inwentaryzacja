class ArchivesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index, :datatables_index_group, :datatables_index_user, :help_new_edit]
  before_action :set_archive, only: [:show, :edit, :update, :destroy, :send_link_to_archive_show]


  def datatables_index_group
    checked_filter = (params[:checked_only_filter].blank? || params[:checked_only_filter] == 'false' ) ? nil : true
    respond_to do |format|
      format.json { render json: GroupArchivesDatatable.new(params, view_context: view_context, only_for_current_group_id: params[:group_id], checked_only_filter: checked_filter) }
    end
  end

  def datatables_index_user
    checked_filter = (params[:checked_only_filter].blank? || params[:checked_only_filter] == 'false' ) ? nil : true
    respond_to do |format|
      format.json { render json: UserArchivesDatatable.new(params, view_context: view_context, only_for_current_user_id: params[:user_id], checked_only_filter: checked_filter) }
    end
  end

  def datatables_index
    # always set user_filter if current_user not have role archive:index
    if policy(:archive).index_in_role? 
      user_filter = (params[:eager_filter_for_current_user].blank? || params[:eager_filter_for_current_user] == 'false' ) ? nil : current_user.id
    else
      user_filter = current_user.id
    end

    respond_to do |format|
      format.json { render json: ArchiveDatatable.new(params, view_context: view_context, eager_filter: user_filter ) }
    end
  end

  def index
    authorize :archive, :index?
    respond_to do |format|
      # disable button all/my if current_user not have role archive:index
      format.html { render :index, locals: {index_in_role: policy(:archive).index_in_role?} }
    end
  end

  def show
    unless @archive.present?
      flash[:error] = t('errors.messages.not_found_resource')
      skip_authorization
      redirect_to root_path()
    else
      authorize @archive, :show?
      respond_to do |format|
        format.html { render :show }
      end
    end
  end

  # GET /archives/new
  def new
    @archive = Archive.new
    @archive.author = current_user
    @archive.quota = Rails.application.secrets[:archive_default_quota]
    @archive.expiry_on = Time.zone.today + Rails.application.secrets.archive_default_days_expiry_on_create.days
    authorize @archive, :new?
  end

  def help_new_edit
  end

  # GET /archives/1/edit
  def edit
    authorize @archive, :edit?
  end

  # POST /archives
  # POST /archives.json
  def create
    @archive = Archive.new(archive_params_create)
    @archive.author = current_user
    authorize @archive, :create?
    respond_to do |format|
      if @archive.save
        @archive.log_work('create', current_user.id)
        format.html { 
          flash[:success] = t('activerecord.successfull.messages.created', data: @archive.fullname)
          redirect_to archive_path(@archive.id) 
        }
        format.json { render :show, status: :created, location: @archive }
      else
        format.html { render :new }
        format.json { render json: @archive.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /archives/1
  # PATCH/PUT /archives/1.json
  def update
    @archive.author = current_user
    authorize @archive, :update?
    respond_to do |format|
      if @archive.update(archive_params)
        @archive.log_work('update', current_user.id)
        format.html { 
          flash[:success] = t('activerecord.successfull.messages.updated', data: @archive.fullname)
          redirect_to archive_path(@archive.id) 
        }
        format.json { render :show, status: :ok, location: @archive }
      else
        format.html { render :edit }
        format.json { render json: @archive.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /archives/1
  # DELETE /archives/1.json
  def destroy
    authorize @archive, :destroy?
    destroyed_clone = @archive.clone
    if @archive.destroy
      destroyed_clone.log_work('destroy', current_user.id)
      flash[:success] = t('activerecord.successfull.messages.destroyed', data: @archive.fullname)
      redirect_to archives_url
    else 
      flash.now[:error] = t('activerecord.errors.messages.destroyed', data: @archive.fullname)
      render :show
    end      
  end

  def send_link_to_archive_show
    authorize @archive, :send_link_to_archive_show?

    if params[:users_ids].blank?
      respond_to do |format|
        format.js { render :blank_users_ids }
      end
    else
      params[:users_ids].each do |i|
        user = User.find(i)
        CloudMailer.link_archive_show(@archive, user, current_user).deliver_later
      end
      respond_to do |format|
        format.js
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archive
      @archive = Archive.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def archive_params
      # params.require(:archive).permit(:name, :note)
      params.require(:archive).permit(policy(@archive).permitted_attributes)      
      # params.require(:archive).permit(:name, :note, archivizations_attributes: [:id, :archives_id, :group_id, :archivization_type_id, :_destroy])
    end

    def archive_params_create
      # params.require(:archive).permit(:name, :note)
      params.require(:archive).permit(policy(:archive).permitted_attributes)      
      # params.require(:archive).permit(:name, :note, archivizations_attributes: [:id, :archives_id, :group_id, :archivization_type_id, :_destroy])
    end

end
