# rubocop:disable Metrics/BlockLength
desc 'Deploy Schema Registry ELB'
task :'deploy:elb' do
  puts 'deploy elb cloudformation template'
  stack_name = 'KSQL-ELB'

  public_subnets = get_subnets('public')
  public_sg = @keystore.retrieve('PUBLIC_SECURITY_GROUP')

  parameters = {
    'VpcId' => @keystore.retrieve('VPC_ID'),
    'SubnetIds' => public_subnets,
    'SecurityGroupId' => public_sg,
    'Port' => @port,
    'SslCertArn' => @keystore.retrieve('SSL_CERT_ARN')
  }

  @cloudformation.deploy_stack(
    stack_name,
    parameters,
    'provisioning/elb.yml'
  )
  puts 'done!'
end

desc 'Deploy KSQL Server ECS'
task :'deploy:ecs' do
  puts 'deploy ecs cloudformation template'
  stack_name = 'KSQL-ECS'
  service_name = 'ksql-server'
  private_subnets = get_subnets('private')
  private_sg = @keystore.retrieve('PRIVATE_SECURITY_GROUP')
  target_group = \
    @cloudformation.stack_output('SCHEMA-REGISTRY-ELB', 'TargetGroup')
  kafka_url = @keystore.retrieve('KAFKA_BOOTSTRAP_SERVERS')
  image_name = 'confluentinc/cp-ksql-server:5.1.0'
  ecs_cluster = 'EX-INTERNAL-ECS-CLUSTER'

  parameters = {
    'Cluster' => ecs_cluster,
    'ServiceName' => service_name,
    'VPC' => @keystore.retrieve('VPC_ID'),
    'PrivateSubnetIds' => private_subnets,
    'EcsSecurityGroup' => private_sg,
    'TargetGroup' => target_group,
    'Image' => image_name,
    'Port' => @port,
    'KafkaUrl' => kafka_url
  }

  @cloudformation.deploy_stack(
    stack_name,
    parameters,
    'provisioning/fargate.yml',
    ['CAPABILITY_NAMED_IAM']
  )
  puts 'done!'
end
# rubocop:enable Metrics/BlockLength
