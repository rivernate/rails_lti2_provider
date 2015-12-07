module RailsLti2Provider
  class ToolProxyRegistration

    attr_reader :tool_consumer_profile, :registration_state, :return_url

    attr_writer :shared_secret, :tool_proxy, :tool_profile, :security_contract, :product_instance, :resource_handlers

    def initialize(registration_request, controller)
      @controller = controller
      @return_url = registration_request.launch_presentation_return_url
      @registration_service = IMS::LTI::Services::ToolProxyRegistrationService.new(registration_request)
      @tool_consumer_profile = @registration_service.tool_consumer_profile
      @registration_state = :not_registered
    end

    def shared_secret
      @shared_secret ||= SecureRandom.hex(64)
    end

    def tool_proxy
      unless @tool_proxy
        @tool_proxy ||= IMS::LTI::Models::ToolProxy.new(
            id: 'defined_by_tool_consumer',
            lti_version: 'LTI-2p0',
            security_contract: security_contract,
            tool_consumer_profile: tool_consumer_profile.id,
            tool_profile: tool_profile,
        )
        if @tool_consumer_profile.capabilities_offered.include?('OAuth.splitSecret')
          @tool_proxy.enabled_capability ||= []
          @tool_proxy.enabled_capability << 'OAuth.splitSecret'
        end
        @tool_proxy
      end
      @tool_proxy
    end

    def tool_profile
      @tool_profile ||= IMS::LTI::Models::ToolProfile.new(
          lti_version: 'LTI-2p0',
          product_instance: product_instance,
          resource_handler: resource_handlers,
          base_url_choice: base_url_choice
      )
    end

    def base_url_choice
      [IMS::LTI::Models::BaseUrlChoice.new(default_base_url: @controller.request.base_url)]
    end

    def product_instance
      unless @product_instance
        product_instance_config = Rails.root.join('config', 'product_instance.json')
        raise 'MissingProductInstaceConfig' unless File.exist? product_instance_config
        @product_instance = IMS::LTI::Models::ProductInstance.new.from_json(File.read(product_instance_config))
      end
    end

    def security_contract
      unless @security_contract
        if @tool_consumer_profile.capabilities_offered.include?('OAuth.splitSecret')
          @security_contract = IMS::LTI::Models::SecurityContract.new(tp_half_shared_secret: shared_secret)
        else
          @security_contract = IMS::LTI::Models::SecurityContract.new(shared_secret: shared_secret)
        end
      else
        @security_contract
      end
    end

    def self.register(registration, controller)
      registration_request = registration.registration_request
      raise 'ToolProxyAlreadyRegisteredException' if registration.workflow_state == :registered
      registration_service = IMS::LTI::Services::ToolProxyRegistrationService.new(registration_request)
      tool_proxy = registration.tool_proxy
      return_url = registration.registration_request.launch_presentation_return_url
      begin
        registered_proxy = registration_service.register_tool_proxy(tool_proxy)
        tool_proxy.tool_proxy_guid = registered_proxy.tool_proxy_guid
        tool_proxy.id = controller.send(engine_name).show_tool_url(registered_proxy.tool_proxy_guid)
        if tc_secret = registered_proxy.tc_half_shared_secret
          shared_secret = tc_secret + tool_proxy.security_contract.tp_half_shared_secret
        else
          shared_secret = tool_proxy.security_contract.shared_secret
        end
        tp = Tool.create!(shared_secret: shared_secret, uuid: registered_proxy.tool_proxy_guid, tool_settings: tool_proxy.as_json, lti_version: tool_proxy.lti_version)
        registration.update(workflow_state: 'registered', tool: tp)
        {
            tool_proxy_uuid: tool_proxy.tool_proxy_guid,
            return_url: return_url,
            status: 'success'
        }
      end
    end

    def self.reregister(registration, controller)
      registration_request = registration.registration_request
      raise 'ToolProxyAlreadyRegisteredException' if [:registered, :rereg_pending].include?(registration.workflow_state)
      registration_service = IMS::LTI::Services::ToolProxyRegistrationService.new(registration_request)
      tool_proxy = registration.tool_proxy
      tool_proxy.tool_proxy_guid = registration.tool.uuid
      return_url = registration.registration_request.launch_presentation_return_url
      tool = registration.tool
      begin
        confirmation_url = controller.send(engine_name).rereg_confirmation_url(tool.uuid, correlation_id: registration.correlation_id)
        registered_proxy = registration_service.register_tool_proxy(tool_proxy, confirmation_url, tool.shared_secret)
        registration.update(workflow_state: 'rereg_pending', tool_proxy_json: registered_proxy.as_json)
        {
            tool_proxy_uuid: tool_proxy.tool_proxy_guid,
            return_url: return_url,
            status: 'success'
        }
      end
    end

    def resource_handlers
      @resource_handlers ||= RailsLti2Provider::RESOURCE_HANDLERS.map do |handler|
        IMS::LTI::Models::ResourceHandler.from_json(
            {
                resource_type: {code: handler['code']},
                resource_name: handler['name'],
                message: messages(handler['messages'])
            }
        )
      end
    end

    private

    def messages(messages)
      messages.map do |m|
        {
            message_type: m['type'],
            path: Rails.application.routes.url_for(only_path: true, host: @controller.request.host_with_port, controller: m['route']['controller'], action: m['route']['action']),
            parameter: parameters(m['parameters']),
            enabled_capability: capabilities(m)
        }
      end
    end

    def parameters(params)
      (params || []).map do |p|
        #TODO: check if variable parameters are in the capabilities offered
        IMS::LTI::Models::Parameter.new(p.symbolize_keys)
      end
    end

    def capabilities(message)
      req_capabilities = message['required_capabilities'] || []
      opt_capabilities = message['optional_capabilities'] || []
      raise UnsupportedCapabilitiesError unless (req_capabilities - (tool_consumer_profile.capability_offered || [])).size == 0
      req_capabilities + opt_capabilities
    end

    def self.engine_name
      engine = Rails.application.routes.named_routes.routes.values.find do |r|
        r.app.class.name == 'Class' && r.app.name == "RailsLti2Provider::Engine"
      end
      engine.name
    end

    class UnsupportedCapabilitiesError < StandardError
    end

  end
end
