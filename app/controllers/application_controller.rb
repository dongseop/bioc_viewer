class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # before_action :restrict_use

  def allowed_user?
    users = ['dongseop@gmail.com', 'sun.kim@nih.gov', 'sooyong.shin@gmail.com']
    return current_user && users.include?(current_user.email)
  end

  def restrict_use
    logger.debug("#{params[:controller] == 'projects'} #{params[:controller] == 'documents'} #{current_user.nil?} #{allowed_user?}")
    if (params[:controller] == 'projects' || params[:controller] == 'documents') &&
          (!current_user.nil? && !allowed_user?)
      redirect_to '/home/index', notice: 'BioC-Viewer is not available for service upgrade.'
    end 
  end
end
