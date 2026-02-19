class ApplicationController < ActionController::Base
before_action :authenticate_user! # Badha page mate login farajiyat  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
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

before action :set_cache_buster
protected 
def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
