desc 'Create dirs ssh-public and git-actions'
task :create_ssh_dirs => :environment do
  unless Dir.exists?("#{Setting.plugin_chiliproject_git['dir_ssh_public']}")
    Dir.mkdir("#{Setting.plugin_chiliproject_git['dir_ssh_public']}")
  end
  unless Dir.exists?("#{Setting.plugin_chiliproject_git['dir_git_actions']}")
    Dir.mkdir("#{Setting.plugin_chiliproject_git['dir_git_actions']}")
  end
end
