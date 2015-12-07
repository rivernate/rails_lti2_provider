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

    def apply_rereg
      tool = Tool.where(uuid: params[:tool_proxy_guid]).first
      registration = tool.registrations.where(correlation_id: params[:correlation_id]).first
      render status: :not_found and return unless registration
      tool_proxy = tool.tool_proxy
      registered_proxy = registration.tool_proxy
      if tc_secret = registered_proxy.tc_half_shared_secret
        shared_secret = tc_secret + tool_proxy.security_contract.tp_half_shared_secret
      else
        shared_secret = tool_proxy.security_contract.shared_secret
      end
      tool.transaction do
        tool.shared_secret= shared_secret
        tool.tool_settings = registered_proxy.as_json
        tool.lti_version = registered_proxy.lti_version
        tool.save!
        registration.update!(workflow_state: 'registered')
      end
      render nothing: true
    end

    def delete_rereg
      tool = Tool.where(uuid: params[:tool_proxy_guid]).first
      registration = tool.registrations.where(correlation_id: params[:correlation_id]).first
      render status: :not_found and return unless registration
      registration.delete!
    end

  end
end
