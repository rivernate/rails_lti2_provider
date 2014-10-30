module RailsLti2Provider
  module ControllerHelpers

    def lti2_authentication
      @lti_message = IMS::LTI::Models::Messages::BasicLTILaunchRequest.new(params)
      @lti_message.launch_url = request.url
      RailsLti2Provider::LtiLaunch.check_launch(@lti_message)
    end

    def disable_xframe_header
      response.headers.except! 'X-Frame-Options'
    end

    def registration_request
      registration_request = IMS::LTI::Models::Messages::RegistrationRequest.new(params)
      @registration = RailsLti2Provider::Registration.create!(
        registration_request_params: registration_request.post_params,
        tool_proxy_json: RailsLti2Provider::ToolProxyRegistration.new(registration_request, self).tool_proxy.as_json
      )
    end

    def register_proxy(registration)
      RailsLti2Provider::ToolProxyRegistration.register(registration, self)
    end

    def redirect_to_consumer(registration_result)
      if registration_result[:status] == 'success'
        redirect_to registration_result[:return_url], {status: 'success', tool_proxy_guid: registration_result[:tool_proxy_uuid]}
      else
        redirect_to registration_result[:return_url], {status: 'error', tool_proxy_guid: registration_result[:tool_proxy_uuid]}
      end
    end

  end
end