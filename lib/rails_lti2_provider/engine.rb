module RailsLti2Provider
  RESOURCE_HANDLERS = []

  class Engine < ::Rails::Engine
    isolate_namespace RailsLti2Provider

    initializer 'resource_handlers' do |app|
      controllers = {}
      Dir[Rails.root.join('config', 'resource_handlers', '*.yml')].each do |yml|
        config = YAML.load(File.read(yml)).with_indifferent_access
        RESOURCE_HANDLERS << config
      end
    end

  end
end
