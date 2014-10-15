module RailsLti2Provider::Concerns::Controllers::ToolProxyController
  extend ActiveSupport::Concern

  included do
    def register
      registration_request = IMS::LTI::Models::Messages::RegistrationRequest.new(params)
      registrar = RailsLti2Provider::ToolProxyRegistration.new(registration_request, self)
      result = registrar.register
      if result.has_key?(:success)
        redirect_to result[:return_url], {status: 'success', tool_proxy_guid: result[:tool_proxy_uuid]}
      else
        redirect_to result[:return_url], {status: 'error', tool_proxy_guid: result[:tool_proxy_uuid]}
      end
    end

    def show

    end


  end

end