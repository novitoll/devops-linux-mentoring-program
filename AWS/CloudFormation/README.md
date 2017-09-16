## Stack of stacks
Templates for AWS CloudFormation stacks build:
- web stack: php, php-mysql, Apache httpd
- db stack: MySQL 5.6
- security: 4 Security Groups for ELB, EC2, RDS
- networking: 1 VPC, 2 EIPs, 2 Public subnets per AZ, 2 Private subnets per AZ, 2 NATGateways, 1 IGW, Route tables per AZ

`main.yml` is the main stack template.
