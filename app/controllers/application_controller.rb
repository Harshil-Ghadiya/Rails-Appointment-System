class ApplicationController < ActionController::Base
  allow_browser versions: :modern


  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes


def after_sign_in_path_for(resource)
  if resource.has_role?(:superadmin)
    superadmin_dashboard_path # Super Admin 
  elsif resource.has_role?(:admin)
    admin_dashboard_path # Org Admin 
  else
    root_path
  end
end

def after_sign_out_path_for(resource_or_scope)
  new_user_session_path
end
end
