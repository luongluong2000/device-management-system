class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :set_locale
  before_action :authenticate_user!
  layout :app_layout

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html{redirect_to root_path, alert: exception.message}
      format.json{head :forbidden, content_type: "text/html"}
      format.js{head :forbidden, content_type: "text/html"}
    end
  end

  private

  def set_locale
    locale = params[:locale]&.strip&.to_sym
    I18n.locale = I18n.available_locales.include?(locale) ? locale : I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def app_layout
    devise_controller? ? "with_out_login" : "application"
  end
end
