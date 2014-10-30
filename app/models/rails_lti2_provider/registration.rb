module RailsLti2Provider
  class Registration < ActiveRecord::Base

    serialize :tool_proxy_json, JSON
    serialize :registration_request_params, JSON

    def register

    end


    def registration_request
      @registration_request ||= IMS::LTI::Models::Messages::RegistrationRequest.new(registration_request_params)
    end

    def tool_proxy
      IMS::LTI::Models::ToolProxy.from_json(self.tool_proxy_json)
    end

  end
end
