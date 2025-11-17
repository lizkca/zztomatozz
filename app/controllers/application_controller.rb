class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :ensure_visitor_id

  private

  def ensure_visitor_id
    return if cookies[:visitor_id].present?
    cookies.permanent[:visitor_id] = SecureRandom.uuid
  end
end
