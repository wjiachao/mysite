# encoding: utf-8
class Admin::BasesController < ActionController::Base
  protect_from_forgery
  layout "admin_layout"


private
  def admin_login_required
    redirect_to(admin_login_path) unless is_login?
  end

end