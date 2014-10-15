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

  end
end