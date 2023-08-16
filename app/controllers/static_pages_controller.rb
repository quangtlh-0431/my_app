class StaticPagesController < ApplicationController
  protect_from_forgery with: :exception
  before_action :set_locale

  def home; end

  def help; end

  def contact; end
end

def set_locale
  I18n.locale = params[:locale] || I18n.default_locale
end
