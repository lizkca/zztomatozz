class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :ensure_visitor_id
  before_action :set_current_user
  before_action :set_locale

  private

  def ensure_visitor_id
    return if cookies[:visitor_id].present?
    cookies.permanent[:visitor_id] = SecureRandom.uuid
  end

  def set_current_user
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_user
    @current_user
  end

  helper_method :current_user

  def set_locale
    loc = params[:locale]&.to_sym
    if loc && I18n.available_locales.include?(loc)
      I18n.locale = loc
      cookies.permanent[:locale] = loc
    else
      I18n.locale = (cookies[:locale]&.to_sym if I18n.available_locales.include?(cookies[:locale]&.to_sym)) || I18n.default_locale
    end
  end
end
