require 'redmine'

Redmine::Plugin.register :chiliproject_git do
  name 'Chiliproject Git plugin'
  author 'Denis Karyakin'
  description 'This is a plugin for ChiliProject, added support of git server (girar)'
  version '0.0.1'
  settings :default => {
      'max_file_ssh_size' => 2048,
      'dir_ssh_public' => "#{RAILS_ROOT}/ssh-public", #todo изменить путь, чтобы файлы не лежали в рельсах
  }, :partial => 'settings/index'

#Menu
  #menu :account_menu, :gittoi, {:controller => 'gittoi', :action => 'index'},
  #     :caption => :label_plugin_gittoi_name, :if => Proc.new { User.current.logged? }, :before => :logout
  #menu :admin_menu, :gittoi, {:controller => 'gittoi', :action => 'admin'},
  #     :caption => :label_plugin_gittoi_name, :after => :users
end
