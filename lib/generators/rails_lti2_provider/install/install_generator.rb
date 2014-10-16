class RailsLti2Provider::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def create_product_instance_json
    template "product_instance.json.erb", "config/product_instance.json"
  end

  private
  def uuid
    SecureRandom.uuid
  end

  def created_at
    Time.now.xmlschema
  end

end
