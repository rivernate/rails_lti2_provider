module RailsLti2Provider
  class ToolsController < ApplicationController
    include RailsLti2Provider::ControllerHelpers

    before_filter :registration_request, only: :register

    def register
      redirect_to_consumer(register_proxy(@registration))
    end

    #alternative action for custom registration workflow
    def submit_proxy
      registration = RailsLti2Provider::Registration.find(params[:registration_uuid])
      begin
        response = register_proxy(registration)
      rescue IMS::LTI::ToolProxyRegistrationError
        response = {
            return_url: registration.registration_request.launch_presentation_return_url,
            status: 'error',
            message: "Failed to create a tool proxy",
        }
      end
      redirect_to_consumer(response)
    end

    def show

    end

  end
end
