json.extract! user, :id, :user_name, :first_name, :last_name, :email, :fullname, :created_at, :updated_at
json.url user_url(user, format: :json)
