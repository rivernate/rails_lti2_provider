class UpdateToolIdType < ActiveRecord::Migration
  def change

    change_column :rails_lti2_provider_lti_launches, :tool_id, :integer, limit: 8
    change_column :rails_lti2_provider_registrations, :tool_id, :integer, limit: 8

  end
end
