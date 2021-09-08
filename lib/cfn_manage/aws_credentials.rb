require 'aws-sdk-core'

module CfnManage

  class AWSCredentials

    def self.get_session_credentials(session_name)

      #check if AWS_ASSUME_ROLE exists
      session_name =  "#{session_name.gsub('_','-')}-#{Time.now.getutc.to_i}"
      if session_name.length > 64
        session_name = session_name[-64..-1]
        $log.info("DEBUG: Aws_Credentials - Session_name truncated")
      end
      assume_role = ENV['AWS_ASSUME_ROLE'] or nil
      if not assume_role.nil?
        $log.info("DEBUG: Aws_Credentials - Env Var AWS_ASSUME_ROLE found")
        return Aws::AssumeRoleCredentials.new(
            role_arn: assume_role,
            role_session_name: session_name
        )
      end

      # check if explicitly set shared credentials profile
      if ENV.key?('CFN_AWS_PROFILE')
        $log.info("DEBUG: Aws_Credentials - CFN_AWS_PROFILE env found")
        return Aws::SharedCredentials.new(profile_name: ENV['CFN_AWS_PROFILE'])
      end

      # check if Instance Profile available
      credentials = Aws::InstanceProfileCredentials.new(http_debug_output: $log.info) # Removed http_open_timeout (1 second, default is 5) and retries (2, default is 5)
      if not credentials.access_key_id.nil?
        $log.info("DEBUG: Aws_Credentials - InstanceProfileCredentials found")
        return credentials

      # check for ECS task credentials available
      credentials = Aws::ECSCredentials.new(http_debug_output: $log.info) # Removed retries (2, default is 5)
      if not credentials.credentials.access_key_id.nil?
        $log.info("DEBUG: Aws_Credentials - ECSCredentials found")
        return credentials unless credentials.credentials.access_key_id.nil?

      # use default profile
      $log.info("DEBUG: Aws_Credentials - No other AWS credentials found, using default")
      return Aws::SharedCredentials.new()

    end
  end
end
