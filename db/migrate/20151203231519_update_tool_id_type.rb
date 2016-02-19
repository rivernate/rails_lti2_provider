class UpdateToolIdType < ActiveRecord::Migration
  def change

    change_column :rails_lti2_provider_lti_launches, :tool_id, "bigint USING CAST(tool_id AS bigint)"
    change_column :rails_lti2_provider_registrations, :tool_id,"bigint USING CAST(tool_id AS bigint)"

  end
end
