class CreateAdminService
  def call(creator_id=nil)
    user = User.find_or_create_by!(email: Rails.application.secrets.admin_email) do |user|
        user.user_name = Rails.application.secrets.admin_name
        user.note = 'Wbudowane konto Administratora Głównego'
        user.author_id = creator_id if creator_id.present?
      end
  end

  def call_simple(email, name, pass, department, creator_id=nil)
    user = User.find_or_create_by!(email: "#{email}".downcase) do |user|
        user.user_name = "#{name}"
        user.author_id = creator_id if creator_id.present?
      end
  end

end
