module RailsLti2Provider
  class ToolProxy < ActiveRecord::Base
    validates_presence_of :shared_secret, :uuid, :proxy_json
    serialize :proxy_json, JSON
    has_many :lti_launches
    has_one :tool_proxy
  end
end
