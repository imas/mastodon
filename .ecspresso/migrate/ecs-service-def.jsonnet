// migrateはサービスとして常駐させず ecspresso run で都度起動する。
// このファイルは ecspresso run が RunTask に必要な networkConfiguration /
// launchType を解決するためだけに置いている。ecspresso deploy では参照しない。
local tfstate = std.native('tfstate');

{
  serviceName: 'imastodon-migrate',
  launchType: 'FARGATE',

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
}
