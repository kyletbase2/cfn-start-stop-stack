require 'optparse'
require_relative '../lib/cf_common'
require_relative '../lib/cf_start_stop_environment'
require 'logger'

# exit with usage information
def print_usage_exit(code)
  STDERR.puts(File.open("#{File.expand_path(File.dirname(__FILE__))}/usage.txt").read)
  exit code
end

def print_version
  STDOUT.puts("Name: cfn_manage\nVersion: 0.5.0")
end

# global options
$options = {}
$options['SOURCE_BUCKET'] = ENV['SOURCE_BUCKET']
$options['AWS_ASSUME_ROLE'] = ENV['AWS_ASSUME_ROLE']

# global logger
$log = Logger.new(STDOUT)

# always flush output
STDOUT.sync = true

# parse command line options
OptionParser.new do |opts|

  opts.banner = 'Usage: cfn_manage [command] [options]'

  opts.on('--source-bucket [BUCKET]') do |bucket|
    $options['SOURCE_BUCKET'] = bucket
    ENV['SOURCE_BUCKET'] = bucket
  end

  opts.on('--aws-role [ROLE]') do |role|
    ENV['AWS_ASSUME_ROLE'] = role
  end

  opts.on('--stack-name [STACK_NAME]') do |stack|
    $options['STACK_NAME'] = stack
  end

  opts.on('--asg-name [ASG]') do |asg|
    $options['ASG'] = asg
  end

  opts.on('--rds-instance-id [RDS_INSTANCE_ID]') do |rds|
    $options['RDS_INSTANCE_ID'] = rds
  end

  opts.on('--aurora-cluster-id [AURORA_CLUSTER_ID]') do |cluster|
    $options['AURORA_CLUSTER_ID'] = cluster
  end

  opts.on('--ec2-instance-id [EC2_INSTANCE_ID]') do |ec2|
    $options['EC2_INSTANCE_ID'] = ec2
  end

  opts.on('--spot-fleet-id [SPOT_FLEET]') do |spot|
    $options['SPOT_FLEET'] = spot
  end

  opts.on('--alarm [ALARM]') do |alarm|
    $options['ALARM'] = alarm
  end

  opts.on('-r [AWS_REGION]', '--region [AWS_REGION]') do |region|
    ENV['AWS_REGION'] = region
  end

  opts.on('-p [AWS_PROFILE]', '--profile [AWS_PROFILE]') do |profile|
    ENV['CFN_AWS_PROFILE'] = profile
  end

  opts.on('--dry-run') do
    ENV['DRY_RUN'] = '1'
  end

  opts.on('--continue-on-error') do
    ENV['CFN_CONTINUE_ON_ERROR'] = '1'
  end

  opts.on('--wait-async') do
    ENV['WAIT_ASYNC'] = '1'
    ENV['SKIP_WAIT'] = '1'
  end

  opts.on('--skip_wait') do
    ENV['SKIP_WAIT'] = '1'
  end

end.parse!

command = ARGV[0]

if command.nil?
  print_usage_exit(-1)
end

# execute action based on command
case command
  when 'help'
    print_usage_exit(0)
  when 'version'
    print_version
  # asg commands
  when 'stop-asg'
    Base2::CloudFormation::EnvironmentRunStop.new().start_resource($options['ASG'],'AWS::AutoScaling::AutoScalingGroup')
  when 'start-asg'
    Base2::CloudFormation::EnvironmentRunStop.new().start_resource($options['ASG'],'AWS::AutoScaling::AutoScalingGroup')

  # rds commands
  when 'stop-rds'
    Base2::CloudFormation::EnvironmentRunStop.new().start_resource($options['RDS_INSTANCE_ID'],'AWS::RDS::DBInstance')
  when 'start-rds'
    Base2::CloudFormation::EnvironmentRunStop.new().start_resource($options['RDS_INSTANCE_ID'],'AWS::RDS::DBInstance')

  # aurora cluster commands
  when 'stop-aurora-cluster'
    Base2::CloudFormation::EnvironmentRunStop.new().start_resource($options['AURORA_CLUSTER_ID'],'AWS::RDS::DBCluster')
  when 'start-aurora-cluster'
    Base2::CloudFormation::EnvironmentRunStop.new().start_resource($options['AURORA_CLUSTER_ID'],'AWS::RDS::DBCluster')

  # ec2 instance
  when 'stop-ec2'
    Base2::CloudFormation::EnvironmentRunStop.new().start_resource($options['EC2_INSTANCE_ID'],'AWS::EC2::Instance')
  when 'start-ec2'
    Base2::CloudFormation::EnvironmentRunStop.new().start_resource($options['EC2_INSTANCE_ID'],'AWS::EC2::Instance')

  # spot fleet
  when 'stop-spot-fleet'
    Base2::CloudFormation::EnvironmentRunStop.new().start_resource($options['SPOT_FLEET'],'AWS::EC2::SpotFleet')
  when 'start-spot-fleet'
    Base2::CloudFormation::EnvironmentRunStop.new().start_resource($options['SPOT_FLEET'],'AWS::EC2::SpotFleet')

  # cloudwatch alarm
  when 'disable-alarm'
    Base2::CloudFormation::EnvironmentRunStop.new().start_resource($options['ALARM'],'AWS::CloudWatch::Alarm')
  when 'enable-alarm'
    Base2::CloudFormation::EnvironmentRunStop.new().start_resource($options['ALARM'],'AWS::CloudWatch::Alarm')

  # stack commands
  when 'stop-environment'
    Base2::CloudFormation::EnvironmentRunStop.new().stop_environment($options['STACK_NAME'])
  when 'start-environment'
    Base2::CloudFormation::EnvironmentRunStop.new().start_environment($options['STACK_NAME'])
end
