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
      redirect_to_consumer(register_proxy(registration))
    end

    def show

    end

  end
end
