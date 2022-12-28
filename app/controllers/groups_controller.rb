class GroupsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index, :datatables_index_user]
  before_action :set_group, only: [:show, :edit, :update, :destroy]


  def datatables_index_user
    checked_filter = (params[:checked_only_filter].blank? || params[:checked_only_filter] == 'false' ) ? nil : true
    respond_to do |format|
      format.json { render json: UserGroupsDatatable.new(params, view_context: view_context, only_for_current_user_id: params[:user_id], checked_only_filter: checked_filter) }
    end
  end

  def datatables_index
    respond_to do |format|
      format.json { render json: GroupDatatable.new(params, view_context: view_context) }
    end
  end

  def select2_index
    authorize :group, :index?
    params[:q] = params[:q]
    @groups = Group.order(:name).finder_group(params[:q])
    @groups_on_page = @groups.page(params[:page]).per(params[:page_limit])
    
    render json: { 
      groups: @groups_on_page.as_json(methods: :fullname, only: [:id, :fullname]),
      meta: { total_count: @groups.count }  
    } 
  end

  # GET /groups
  # GET /groups.json
  def index
    authorize :group, :index?
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @for_archive = Archive.find(params[:archive_id]) if params[:archive_id].present? 
    authorize @group, :show?
  end

  # GET /groups/new
  def new
    @group = Group.new
    @group.name = params[:group][:name].strip if params.dig(:group, :name).present? 
    @group.author = current_user
    authorize @group, :new?
  end

  # GET /groups/1/edit
  def edit
    authorize @group, :edit?
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    authorize @group, :create?
    respond_to do |format|
      if @group.save
        @group.log_work('create', current_user.id)
        format.html { 
          flash[:success] = t('activerecord.successfull.messages.created', data: @group.fullname)
          redirect_to @group 
        }
        format.json { render :show, status: :created, location: @group }
        format.js { render :create }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    authorize @group, :update?
    respond_to do |format|
      # if @group.update(name: params[:group][:name], note: params[:group][:note], special: params[:group][:special],activities: params[:group][:activities].split)
      if @group.update(group_params)
        @group.log_work('update', current_user.id)
        format.html { 
          flash[:success] = t('activerecord.successfull.messages.updated', data: @group.fullname)
          redirect_to @group 
        }
        format.json { render :show, status: :ok, location: @group }
        format.js { render :update }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
        format.js { render :edit }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    authorize @group, :destroy?
    destroyed_clone = @group.clone
    if @group.destroy
      destroyed_clone.log_work('destroy', current_user.id)
      flash[:success] = t('activerecord.successfull.messages.destroyed', data: @group.fullname)
      redirect_to groups_url
    else 
      flash.now[:error] = t('activerecord.errors.messages.destroyed', data: @group.fullname)
      #redirect_to :back
      render :show
    end      
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      defaults = { author_id: "#{current_user.id}" }
      params.require(:group).permit(:name, :note, :author_id, members_attributes: [:id, :user_id, :author_id, :_destroy]).reverse_merge(defaults)
    end

end
