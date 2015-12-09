RailsLti2Provider::Engine.routes.draw do

  Rails.application.routes.draw do
    RailsLti2Provider::RESOURCE_HANDLERS.each do |config|
      config[:messages].each do |message|
        route = message[:route].symbolize_keys
        path = route.delete(:path) || ':controller/:action'
        post path, route
      end
    end
  end

  post 'tool_proxy/register', to: 'tools#register', as: :tool_proxy_registration
  get  'tool_proxy/submit_registration/:registration_uuid', to: 'tools#submit_proxy', as: :submit_proxy

  get 'tool_proxy/:tool_proxy_id', to: 'tools#show', as: :show_tool

  put 'tool_proxy/:tool_proxy_guid', to: 'tools#apply_rereg', as: :rereg_confirmation
  delete 'tool_proxy/:tool_proxy_guid', to: 'tools#delete_rereg'


end
