class UkeRegulationsController < ApplicationController

  before_action :authenticate_user!

  # GET /uke_regulations
  # GET /uke_regulations.json
  def index
    # unless Rails.env.development?
    if false
      uke_regulation_obj = UkeRegulation.new(user_name: current_user.email)
      if uke_regulation_obj.check_acceptance
        if JSON.parse(uke_regulation_obj.response.body)['accepted']
          redirect_to root_path
        else
          sign_out if user_signed_in? 
          url = uke_regulation_obj.generate_acceptance_url
          redirect_to "#{url}"
        end
      else
        sign_out if user_signed_in?     
        uke_regulation_obj.errors.full_messages.each do |msg|
          flash[:error] = msg.force_encoding("UTF-8")
        end
        redirect_to root_path
      end
    else
      flash[:warning] = "development mode, UkeRegulations is OFF"
      # flash[:warning] = "Odblokuj UkeRegulations"
      redirect_to root_path      
    end
  end

end

