class CreateRoleService

  #works
  def work_observer(creator_id=nil)
    role = Role.find_or_create_by!(name: "Obserwator Działań") do |role|
      role.activities += %w(all:work role:work user:work group:work archive:work)
      role.note = "<div>Rola służy do obserwowania historii wpisów, działań.<br>(Przypisz tylko Administratorom systemu)</div>"
      role.author_id = creator_id
      role.save!
    end
  end

  # roles
  def role_admin(creator_id=nil)
    role = Role.find_or_create_by!(name: "Administrator Ról Systemowych") do |role|
      role.activities += %w(role:index role:show role:create role:update role:delete role:work)
      role.note = "<div>Rola służy do tworzenia, modyfikowania Ról.<br>(Przypisz tylko zaawansowanym Administratorom systemu)</div>"
      role.author_id = creator_id
      role.save!
    end
  end 

  # users
  def user_admin(creator_id=nil)
    role = Role.find_or_create_by!(name: "Administrator Użytkowników") do |role|
      role.activities += %w(user:index user:show user:create user:update user:delete role:add_remove_role_user user:work)
      role.note = "<div>Rola służy do zarządzania Użytkownikami i przypisywania im Ról Systemowych.<br>(Przypisz tylko zaawansowanym Administratorom systemu)</div>"
      role.author_id = creator_id
      role.save!
    end
  end
  def user_writer(creator_id=nil)
    role = Role.find_or_create_by!(name: "Kreator Użytkowników") do |role|
      role.activities += %w(user:index user:show user:create)
      role.note = "<div>Rola służy do tworzenia kont Użytkowników, którym udostępnione mają być Składnice.<br>(Przypisz tylko zaawansowanym użytkownikom systemu, którzy mają tworzyć konta użytkowników z dostępem do Składnic)</div>"
      role.author_id = creator_id
      role.save!
    end
  end

  def user_observer(creator_id=nil)
    role = Role.find_or_create_by!(name: "Obserwator Użytkowników") do |role|
      role.activities += %w(user:index user:show)
      role.note = "<div>Rola pozwala przeglądać dane kont Użytkowników.<br>(Przypisz użytkownikom systemu, którzy mają prawo do przeglądania takich danych)</div>"
      role.author_id = creator_id
      role.save!
    end
  end

  # groups
  def group_admin(creator_id=nil)
    role = Role.find_or_create_by!(name: "Administrator Grup") do |role|
      role.activities += %w(group:index group:show group:create group:update group:delete group:work group:add_remove_group_user)
      role.note = "<div>Rola służy do tworzenia, modyfikowania i usuwania Grup.<br>(Przypisz tylko zaawansowanym Administratorom systemu)</div>"
      role.author_id = creator_id
      role.save!
    end
  end 
  def group_writer(creator_id=nil)
    role = Role.find_or_create_by!(name: "Kreator Grup") do |role|
      role.activities += %w(group:index group:show group:create group:update group:add_remove_group_user)
      role.note = "<div>Rola służy do tworzenia, modyfikowania Grup, bez prawa ich usuwania.<br>(Przypisz tylko zaawansowanym użytkownikom systemu, którzy mają tworzyć Grupy)</div>"
      role.author_id = creator_id
      role.save!
    end
  end 
  def group_observer(creator_id=nil)
    role = Role.find_or_create_by!(name: "Obserwator Grup") do |role|
      role.activities += %w(group:index group:show)
      role.note = "<div>Rola pozwala przeglądać dane Grup.<br>(Przypisz użytkownikom, którzy mają prawo do przeglądania takich danych)</div>"
      role.author_id = creator_id
      role.save!
    end
  end 

  # archives
  def archive_admin(creator_id=nil)
    role = Role.find_or_create_by!(name: "Administrator Składnic") do |role|
      role.activities += %w(archive:index archive:show archive:show_expiried archive:create archive:update archive:delete archive:work archive:add_remove_archive_group)
      role.note = "<div>Rola służy do zarządzania wszystkimi Składnicami.<br>(Przypisz tylko zaawansowanym Administratorom systemu)</div>"
      role.author_id = creator_id
      role.save!
    end
  end 
  def archive_writer(creator_id=nil)
    role = Role.find_or_create_by!(name: "Kreator Składnic") do |role|
      role.activities += %w(archive:index archive:create archive:show_self archive:show_expiried_self archive:update_self archive:delete_self archive:add_remove_archive_group_self)
      role.note = "<div>Rola służy do tworzenia Składnic oraz zarządzania własnymi składnicami.<br>(Przypisz osobom, które będą tworzyły składnice)</div>"
      role.author_id = creator_id
      role.save!
    end
  end 
  def archive_observer(creator_id=nil)
    role = Role.find_or_create_by!(name: "Obserwator Składnic") do |role|
      role.activities += %w(archive:index archive:show)
      role.note = "<div>Rola służy do wyświetlania informacji o Składnicach.</div>"
      role.author_id = creator_id
      role.save!
    end
  end

end
