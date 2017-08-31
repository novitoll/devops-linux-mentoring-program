### AWS
- 2x EC2 t2.micro Amazon Linux instances
- 1x ELB
- 1x CDN CloudFront with 1x ELB origin with HTTPS
- 2x S3 buckets:
  - backup-aws-sabrtasbolatov bucket with own bucket policy
  - web-aws-sabrtasbolatov -- static web hosting bucket
- 1x Auto-Scaling Group with Launch Configuration using "asg_launch_configuration_user_data.sh" user data to provision instances
