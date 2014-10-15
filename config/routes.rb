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

  post 'tool_proxy/register', to: 'tool_proxy#register', as: :tool_proxy_registrar

  get 'tool_proxy/:tool_proxy_id', to: 'tool_proxy#show', as: :show_tool_proxy


end
