class Archives::ComponentsController < ComponentsController
  before_action :set_componentable

  private

    def set_componentable
      @componentable = Archive.find(params[:archive_id])
    end

end