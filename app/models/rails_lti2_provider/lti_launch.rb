module RailsLti2Provider
  class LtiLaunch < ActiveRecord::Base
    validates_presence_of :tool_proxy_id, :nonce
    has_one :tool_proxy
    serialize :message

    def self.check_launch(lti_message)
      tool_proxy = ToolProxy.find_by_uuid(lti_message.oauth_consumer_key)
      valid_launch = lti_message.valid_signature?(tool_proxy.shared_secret) &&
        tool_proxy.lti_launches.where(nonce: lti_message.oauth_nonce).count == 0 &&
        DateTime.strptime(lti_message.oauth_timestamp,'%s') > 5.minutes.ago
      raise Unauthorized unless valid_launch
      tool_proxy.lti_launches.where('created_at > ?', 1.day.ago).delete_all
      tool_proxy.lti_launches.create(nonce: lti_message.oauth_nonce, message: lti_message.post_params)
      lti_message
    end

    class Unauthorized < StandardError;
    end


  end
end
