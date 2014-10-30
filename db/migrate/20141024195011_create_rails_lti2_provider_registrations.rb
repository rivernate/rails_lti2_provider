class CreateRailsLti2ProviderRegistrations < ActiveRecord::Migration
  def change
    create_table :rails_lti2_provider_registrations do |t|
      t.string :uuid
      t.text :registration_request_params
      t.text :tool_proxy_json
      t.string :workflow_state

      t.timestamps
    end
  end
end
