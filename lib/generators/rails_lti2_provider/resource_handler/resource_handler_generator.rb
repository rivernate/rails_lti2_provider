class RailsLti2Provider::ResourceHandlerGenerator  < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :name, type: :string
  class_option :code, type: :string
  class_option :description, type: :string
  class_option :route_path, type: :string
  class_option :controller, type: :string
  class_option :action, type: :string



  def create_resource_handler
    template "resource_handler.yml.erb", "config/resource_handlers/#{name.underscore}.yml"
  end

end