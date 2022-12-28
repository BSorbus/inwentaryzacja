#json.extract! group, :id, :name, :note, :fullname, :created_at, :updated_at
json.extract! group, :id, :fullname
json.url group_url(group, format: :json)
