class RegistrationController < ApplicationController
  include RailsLti2Provider::ControllerHelpers

  before_filter :registration_request, only: :register
  protect_from_forgery except: :register
  after_filter :disable_xframe_header, only: :register


  def register
    redirect_to rails_lti2_provider.submit_proxy_path(@registration.id)
  end


end