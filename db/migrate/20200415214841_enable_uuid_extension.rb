class EnableUuidExtension < ActiveRecord::Migration[5.2]
  def change
	# enable_extension 'pgcrypto'
	# permission error
	# run psql and call:
	# \c database_name;
	# CREATE EXTENSION IF NOT EXISTS pgcrypto;
  end
end
