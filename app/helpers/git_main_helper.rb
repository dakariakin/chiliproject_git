module GitMainHelper
  def change_status_link(user)
    if user.blocked == 'T'
      link_to l(:button_unlock), :action => 'update_user', :id => user.id, :class => 'icon icon-unlock'
    elsif user.id != User.current.id
      link_to l(:button_lock), :action => 'update_user', :id => user.id, :class => 'icon icon-lock'
    end
  end
end
