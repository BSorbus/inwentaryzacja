class AddNewArchivizationTypes < ActiveRecord::Migration[5.2]
  def up
      a_type_rwa = ArchivizationType.find_or_create_by!(name: "Pliki wewnątrz: [Odczyt, Zapis, Audyt]") do |ta|
      ta.activities += %w(archivization:index archivization:show archivization:create archivization:update archivization:work)
      ta.need_more_privilage = false
      ta.save!
    end
    puts 'CREATED ArchivizationType: ' << a_type_rwa.name
  end

  def down
    a_type_rwa = ArchivizationType.find_by(name: "Pliki wewnątrz: [Odczyt, Zapis, Audyt]")
    a_type_rwa_name = a_type_rwa.name
    puts 'DESTROYED ArchivizationType: ' << a_type_rwa.name
  end
  
end

# oryginal:
# a_type = ArchivizationType.find_or_create_by!(name: "Pliki wewnątrz: [Odczyt, Zapis, Usuwanie, Audyt]") do |ta|
#   ta.activities += %w(archivization:index archivization:show archivization:create archivization:update archivization:delete archivization:work)
#   ta.need_more_privilage = false
