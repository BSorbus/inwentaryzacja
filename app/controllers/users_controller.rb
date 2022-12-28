class UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :datatables_index_role, :datatables_index_group, :datatables_index]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :account_off, :account_on, :set_activity_at]


  def datatables_index_role
    checked_filter = (params[:checked_only_filter].blank? || params[:checked_only_filter] == 'false' ) ? nil : true
    respond_to do |format|
      format.json { render json: RoleUsersDatatable.new(params, view_context: view_context, only_for_current_role_id: params[:role_id], checked_only_filter: checked_filter) }
    end
  end

  def datatables_index_group
    checked_filter = (params[:checked_only_filter].blank? || params[:checked_only_filter] == 'false' ) ? nil : true
    respond_to do |format|
      format.json { render json: GroupUsersDatatable.new(params, view_context: view_context, only_for_current_group_id: params[:group_id], checked_only_filter: checked_filter) }
    end
  end

  def datatables_index
    respond_to do |format|
      format.json { render json: UserDatatable.new(params, view_context: view_context) }
    end
  end

  def select2_index
    authorize :user, :index?
    #params[:q] = (params[:q]).upcase
    params[:q] = params[:q]
    @users = User.order(:email, :last_name, :first_name).finder_user(params[:q])
    @users_on_page = @users.page(params[:page]).per(params[:page_limit])
    
    render json: { 
      users: @users_on_page.as_json(methods: :fullname, only: [:id, :fullname]),
      meta: { total_count: @users.count }  
    } 
  end

  # GET /users
  # GET /users.json
  def index
    authorize :user, :index?
  end

  # GET /users/1
  # GET /users/1.json
  def show
    authorize @user, :show?
  end

  # GET /users/new
  def new
    @user = User.new
    authorize @user, :new?
  end

  # GET /users/1/edit
  def edit
    authorize @user, :edit?
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    authorize @user, :create?
    respond_to do |format|
      if @user.save
        @user.log_work('create', current_user.id)
        format.html { 
          flash[:success] = t('activerecord.successfull.messages.created', data: @user.fullname)
          redirect_to @user 
        }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    authorize @user, :update?
    respond_to do |format|
      if @user.update(user_params)
        @user.log_work('update', current_user.id)
        format.html { 
          flash[:success] = t('activerecord.successfull.messages.updated', data: @user.fullname)
          redirect_to @user 
        }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    authorize @user, :destroy?
    destroyed_clone = @user.clone
    if @user.destroy
      destroyed_clone.log_work('destroy', current_user.id)
      flash[:success] = t('activerecord.successfull.messages.destroyed', data: @user.fullname)
      redirect_to users_url
    else 
      flash.now[:error] = t('activerecord.errors.messages.destroyed', data: @user.fullname)
      #redirect_to :back
      render :show
    end      
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      defaults = { author_id: "#{current_user.id}" }
      params.require(:user).permit(:email, :note, :author_id).reverse_merge(defaults)
      # params.require(:user).permit(:email, :note, :author_id, role_ids: []).reverse_merge(defaults).tap do |parameters|
        # raise
      # end
    end

end

# , examiners_attributes: [:id, :name, :_destroy]
#       params.require(:role).permit(:name, :note, :activities, :author_id).tap do |parameters|
#         parameters[:activities] = parameters[:activities].try(:split)
#       end
