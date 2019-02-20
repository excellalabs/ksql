desc 'Build ksql server image'
task :'build:image' do
  puts 'build docker image for ksql server'

  # authentication
  system('$(aws ecr get-login --no-include-email --region us-east-1)')

  @docker.build_docker_image(@docker_image, 'container')
  @docker.push_docker_image(@docker_image)

  puts 'done!'
end
