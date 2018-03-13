module RailsLti2Provider
  RESOURCE_HANDLERS = []

  class Engine < ::Rails::Engine
    isolate_namespace RailsLti2Provider

    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.assets false
      g.helper false
    end

    initializer :resource_handlers do |app|
      Dir[Rails.root.join('config', 'resource_handlers', '*.yml')].each do |yml|
        config = YAML.load(File.read(yml)).with_indifferent_access
        RESOURCE_HANDLERS << config
      end
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

  end
end
