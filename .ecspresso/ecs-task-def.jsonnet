local must_env = std.native('must_env');
local tfstate = std.native('tfstate');

{
  family: 'imastodon-sidekiq',
  requiresCompatibilities: ['FARGATE'],
  networkMode: 'awsvpc',
  cpu: '512',
  memory: '1024',
  executionRoleArn: tfstate('module.ecs.aws_iam_role.ecs_task_execution_role.arn'),
  taskRoleArn: tfstate('module.iam.aws_iam_role.imastodon_iam_role.arn'),

  containerDefinitions: [
    // log_router (FireLens) - 他コンテナより先に起動する必要あり
    {
      name: 'log_router',
      image: 'public.ecr.aws/aws-observability/aws-for-fluent-bit:stable',
      essential: true,
      firelensConfiguration: {
        type: 'fluentbit',
        options: {
          'enable-ecs-log-metadata': 'true',
        },
      },
      environment: [
        { name: 'FLB_LOG_LEVEL', value: 'warn' },
      ],
      logConfiguration: {
        logDriver: 'awslogs',
        options: {
          'awslogs-group': '/ecs/imastodon-sidekiq/log_router',
          'awslogs-region': 'us-west-2',
          'awslogs-stream-prefix': 'log_router',
          'awslogs-create-group': 'true',
        },
      },
    },

    // pgbouncer - sidekiqより先に起動
    {
      name: 'pgbouncer',
      image: 'bitnami/pgbouncer:1.23.1',
      essential: true,
      environment: [
        { name: 'POSTGRESQL_HOST', value: tfstate('module.rds.aws_db_instance.imastodon_rds.address') },
        { name: 'POSTGRESQL_PORT', value: '5432' },
        { name: 'PGBOUNCER_PORT', value: '6432' },
        { name: 'PGBOUNCER_POOL_MODE', value: 'transaction' },
        { name: 'PGBOUNCER_MAX_CLIENT_CONN', value: '100' },
        { name: 'PGBOUNCER_DEFAULT_POOL_SIZE', value: '50' },
      ],
      secrets: [
        { name: 'POSTGRESQL_DATABASE', valueFrom: '/imastodon/prod/DB_NAME' },
        { name: 'POSTGRESQL_USERNAME', valueFrom: '/imastodon/prod/DB_USER' },
        { name: 'POSTGRESQL_PASSWORD', valueFrom: '/imastodon/prod/DB_PASS' },
      ],
      dependsOn: [
        { containerName: 'log_router', condition: 'START' },
      ],
      logConfiguration: {
        logDriver: 'awsfirelens',
        options: {
          Name: 'S3',
          region: 'us-west-2',
          bucket: tfstate('module.ecs.aws_s3_bucket.ecs_logs.bucket'),
          's3_key_format': '/pgbouncer/%Y/%m/%d/%H/$UUID.gz',
          'total_file_size': '100M',
          'upload_timeout': '10m',
          Compression: 'gzip',
        },
      },
    },

    // sidekiq-default
    {
      name: 'sidekiq-default',
      image: tfstate('module.ecr.aws_ecr_repository.mastodon.repository_url') + ':' + must_env('IMAGE_TAG'),
      essential: true,
      command: ['bundle', 'exec', 'sidekiq', '-c', '30', '-q', 'default'],
      environment: [
        { name: 'RAILS_ENV', value: 'production' },
        { name: 'DB_POOL', value: '30' },
        { name: 'RUBY_YJIT_ENABLE', value: '1' },
        { name: 'DB_HOST', value: '127.0.0.1' },
        { name: 'DB_PORT', value: '6432' },
        { name: 'PARAMETER_STORE_REGION', value: 'us-west-2' },
        { name: 'PARAMETER_STORE_PREFIX', value: '/imastodon/prod/' },
      ],
      stopTimeout: 120,
      dependsOn: [
        { containerName: 'pgbouncer', condition: 'START' },
        { containerName: 'log_router', condition: 'START' },
      ],
      logConfiguration: {
        logDriver: 'awsfirelens',
        options: {
          Name: 'S3',
          region: 'us-west-2',
          bucket: tfstate('module.ecs.aws_s3_bucket.ecs_logs.bucket'),
          's3_key_format': '/sidekiq-default/%Y/%m/%d/%H/$UUID.gz',
          'total_file_size': '100M',
          'upload_timeout': '10m',
          Compression: 'gzip',
        },
      },
    },

    // sidekiq-misc
    {
      name: 'sidekiq-misc',
      image: tfstate('module.ecr.aws_ecr_repository.mastodon.repository_url') + ':' + must_env('IMAGE_TAG'),
      essential: true,
      command: ['bundle', 'exec', 'sidekiq', '-c', '15'],
      environment: [
        { name: 'RAILS_ENV', value: 'production' },
        { name: 'DB_POOL', value: '15' },
        { name: 'RUBY_YJIT_ENABLE', value: '1' },
        { name: 'DB_HOST', value: '127.0.0.1' },
        { name: 'DB_PORT', value: '6432' },
        { name: 'PARAMETER_STORE_REGION', value: 'us-west-2' },
        { name: 'PARAMETER_STORE_PREFIX', value: '/imastodon/prod/' },
      ],
      stopTimeout: 120,
      dependsOn: [
        { containerName: 'pgbouncer', condition: 'START' },
        { containerName: 'log_router', condition: 'START' },
      ],
      logConfiguration: {
        logDriver: 'awsfirelens',
        options: {
          Name: 'S3',
          region: 'us-west-2',
          bucket: tfstate('module.ecs.aws_s3_bucket.ecs_logs.bucket'),
          's3_key_format': '/sidekiq-misc/%Y/%m/%d/%H/$UUID.gz',
          'total_file_size': '100M',
          'upload_timeout': '10m',
          Compression: 'gzip',
        },
      },
    },
  ],
}
