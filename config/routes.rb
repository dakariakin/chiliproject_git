ActionController::Routing::Routes.draw do |map|
  map.connect '/git_main/bind/:git_id', :controller => 'git_main', :action => 'bind'
end