# lib/tasks/cronjobs.rake

namespace :cronjobs do

  desc "Clean /tmp/zipownia"
  task clean_zipownia: :environment do
    system("rm -rf #{Rails.root}/tmp/zipownia")
  end

end