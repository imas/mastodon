local tfstate = std.native('tfstate');

{
  serviceName: 'imastodon-sidekiq',
  desiredCount: 1,

  capacityProviderStrategy: [
    {
      capacityProvider: 'FARGATE',
      base: 1,
      weight: 0,
    },
    {
      capacityProvider: 'FARGATE_SPOT',
      base: 0,
      weight: 1,
    },
  ],

  networkConfiguration: {
    awsvpcConfiguration: {
      subnets: [
        tfstate('module.network.aws_subnet.imastodon_subnet_public_a.id'),
        tfstate('module.network.aws_subnet.imastodon_subnet_public_c.id'),
      ],
      securityGroups: [
        tfstate('module.network.aws_security_group.imastodon_security_group_sidekiq.id'),
      ],
      assignPublicIp: 'ENABLED',
    },
  },

  deploymentConfiguration: {
    minimumHealthyPercent: 100,
    maximumPercent: 200,
  },

  enableExecuteCommand: true,
}
