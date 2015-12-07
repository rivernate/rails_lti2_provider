module RailsLti2Provider
  module ControllerHelpers

    def lti_authentication
      lti_message = IMS::LTI::Models::Messages::Message.generate(request.request_parameters.merge(request.query_parameters))
      lti_message.launch_url = request.url
      @lti_launch = RailsLti2Provider::LtiLaunch.check_launch(lti_message)
    end


    def disable_xframe_header
      response.headers.except! 'X-Frame-Options'
    end

    def registration_request
      registration_request = IMS::LTI::Models::Messages::Message.generate(params)
      @registration = RailsLti2Provider::Registration.new(
          registration_request_params: registration_request.post_params,
          tool_proxy_json: RailsLti2Provider::ToolProxyRegistration.new(registration_request, self).tool_proxy.as_json
      )
      if registration_request.is_a? IMS::LTI::Models::Messages::ToolProxyReregistrationRequest
        @registration.tool = Tool.where(uuid: params['oauth_consumer_key']).first
        @registration.correlation_id = SecureRandom.hex(64)
      end
      @registration.save!

    end

    def register_proxy(registration)
      if registration.registration_request.is_a? IMS::LTI::Models::Messages::ToolProxyReregistrationRequest
        RailsLti2Provider::ToolProxyRegistration.reregister(registration, self)
      else
        RailsLti2Provider::ToolProxyRegistration.register(registration, self)
      end
    end

    def redirect_to_consumer(registration_result)
      url = registration_result[:return_url]
      url = add_param(url, 'tool_proxy_guid', registration_result[:tool_proxy_uuid])
      if registration_result[:status] == 'success'
        url = add_param(url, 'status', 'success')
        redirect_to url
      else
        url = add_param(url, 'status', 'error')
        redirect_to url
      end
    end

    def add_param(url, param_name, param_value)
      uri = URI(url)
      params = URI.decode_www_form(uri.query || '') << [param_name, param_value]
      uri.query = URI.encode_www_form(params)
      uri.to_s
    end

  end
end