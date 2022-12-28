class Api::V1::ProposalsController < Api::V1::BaseApiController

  respond_to :json

  def index
    if params[:creator_id].blank?
      proposals = Proposal.all
    else
      proposals = Proposal.where(creator_id: params[:creator_id])
    end

    render json: proposals, status: :ok, root: true
  end

  def show
    proposal = Proposal.find_by(id: params[:id])
    if proposal.present?
      render json: proposal, status: :ok, root: false
    else
      render json: { error: "Brak rekordu dla Proposal.where(id: #{params[:id]})" }, status: :not_found
    end
  end

  def update
    params[:proposal] = JSON.parse params[:proposal].gsub('=>', ':')
    proposal = Proposal.find_by(multi_app_identifier: params[:multi_app_identifier])
    if proposal.present?
      if proposal.update(proposal_params)
        render json: proposal, status: :ok
      else
        render json: { errors: proposal.errors }, status: :unprocessable_entity
      end
    else
      render json: { error: "Brak rekordu dla Proposal.where(multi_app_identifier: #{params[:multi_app_identifier]})" }, status: :not_found
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def proposal_params
      params.require(:proposal).permit(:proposal_status_id, :not_approved_comment )
    end

end
