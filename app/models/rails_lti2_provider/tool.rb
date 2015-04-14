module RailsLti2Provider
  class Tool < ActiveRecord::Base
    validates_presence_of :shared_secret, :uuid, :tool_settings, :lti_version
    serialize :tool_settings
    has_many :lti_launches
  end
end
