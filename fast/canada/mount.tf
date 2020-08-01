
provider "aws" {
  region = "ca-central-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.16.0.0/16"
  
  tags = {
    name = "vpc"
    env = "production"
    region = "ca-central-1"
    author = "Lance Pollard"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_lb" "lb" {
  name = "canada"
  internal = false
  load_balancer_type = "application"
  enable_http2 = true
  security_groups = [
    aws_security_group.gateway.id
  ]
  subnets = [
    aws_subnet.ca_central_1a_gateway.id,
    aws_subnet.ca_central_1b_gateway.id,
    aws_subnet.ca_central_1d_gateway.id
  ]
  
  tags = {
    name = "vpc"
    env = "production"
    region = "ca-central-1"
    author = "Lance Pollard"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_lb_target_group" "canada_gateway" {
  port = "80"
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    name = "canada_gateway"
    env = "production"
    region = "ca-central-1"
    author = "Lance Pollard"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_acm_certificate" "canada_gateway" {
  domain_name = "example.com"
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    name = "canada_gateway"
    env = "production"
    region = "ca-central-1"
    author = "Lance Pollard"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_lb_listener" "canada_gateway" {
  load_balancer_arn = aws_lb.lb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.canada_gateway.arn
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.canada_gateway.arn
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    name = "ig"
    env = "production"
    region = "ca-central-1"
    author = "Lance Pollard"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_security_group" "gateway" {
  description = "Allow communication of gateway with internet and compute"
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  ingress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.16.0.0/21",
      "10.16.32.0/21",
      "10.16.64.0/21"
    ]
  }
  
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  egress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.16.0.0/21",
      "10.16.32.0/21",
      "10.16.64.0/21"
    ]
  }
}

resource "aws_security_group" "compute" {
  description = "Allow compute to communicate with internal nodes only"
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"
    ]
  }
  
  egress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"
    ]
  }
}

resource "aws_security_group" "connect" {
  description = "Allow communication of connect nodes"
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.16.0.0/21",
      "10.16.32.0/21",
      "10.16.64.0/21"
    ]
  }
  
  egress {
    from_port = 10000
    to_port = 10000
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  egress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.16.0.0/21",
      "10.16.32.0/21",
      "10.16.64.0/21"
    ]
  }
}

resource "aws_security_group" "storage" {
  description = "Allow storage to communicate with compute nodes only"
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.16.0.0/21",
      "10.16.32.0/21",
      "10.16.64.0/21"
    ]
  }
  
  egress {
    from_port = 11111
    to_port = 11111
    protocol = "tcp"
    cidr_blocks = [
      "10.16.0.0/21",
      "10.16.32.0/21",
      "10.16.64.0/21"
    ]
  }
}

resource "aws_eip" "ca_central_1a_gateway" {
  vpc = true
  network_interface = aws_network_interface.ca_central_1a_gateway.id
  
  tags = {
    name = "ca_central_1a_gateway"
    env = "production"
    zone = "ca-central-1a"
    author = "Lance Pollard"
    region = "ca-central-1"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_nat_gateway" "ca_central_1a_gateway" {
  subnet_id = aws_subnet.ca_central_1a_gateway.id
  allocation_id = aws_eip.ca_central_1a_gateway.id
  
  tags = {
    name = "ca_central_1a_gateway"
    region = "ca-central-1"
    zone = "ca-central-1a"
    author = "Lance Pollard"
    env = "production"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_subnet" "ca_central_1a_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.16.8.0/21"
  availability_zone = "ca-central-1a"
  
  tags = {
    env = "production"
    zone = "ca-central-1a"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1a_gateway"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ca_central_1a_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ca-central-1a"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1a_gateway"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ca_central_1a_gateway" {
  subnet_id = aws_subnet.ca_central_1a_gateway.id
  route_table_id = aws_route_table.ca_central_1a_gateway.id
}

resource "aws_route" "ca_central_1a_gateway_compute" {
  route_table_id = aws_route_table.ca_central_1a_gateway.id
  destination_cidr_block = "10.16.0.0/21"
}

resource "aws_network_interface" "ca_central_1a_gateway" {
  subnet_id = aws_subnet.ca_central_1a_gateway.id
}

resource "aws_subnet" "ca_central_1a_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.16.0.0/21"
  availability_zone = "ca-central-1a"
  
  tags = {
    env = "production"
    zone = "ca-central-1a"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1a_compute"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ca_central_1a_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ca-central-1a"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1a_compute"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ca_central_1a_compute" {
  subnet_id = aws_subnet.ca_central_1a_gateway.id
  route_table_id = aws_route_table.ca_central_1a_compute.id
}

resource "aws_route" "ca_central_1a_compute_storage" {
  route_table_id = aws_route_table.ca_central_1a_compute.id
  destination_cidr_block = "10.16.16.0/21"
}

resource "aws_route" "ca_central_1a_compute_gateway" {
  route_table_id = aws_route_table.ca_central_1a_compute.id
  destination_cidr_block = "10.16.8.0/21"
}

resource "aws_route" "ca_central_1a_compute_connect" {
  route_table_id = aws_route_table.ca_central_1a_compute.id
  destination_cidr_block = "10.16.24.0/21"
}

resource "aws_network_interface" "ca_central_1a_compute" {
  subnet_id = aws_subnet.ca_central_1a_gateway.id
}

resource "aws_subnet" "ca_central_1a_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.16.16.0/21"
  availability_zone = "ca-central-1a"
  
  tags = {
    env = "production"
    zone = "ca-central-1a"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1a_storage"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ca_central_1a_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ca-central-1a"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1a_storage"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ca_central_1a_storage" {
  subnet_id = aws_subnet.ca_central_1a_gateway.id
  route_table_id = aws_route_table.ca_central_1a_storage.id
}

resource "aws_route" "ca_central_1a_storage_compute" {
  route_table_id = aws_route_table.ca_central_1a_storage.id
  destination_cidr_block = "10.16.0.0/21"
}

resource "aws_network_interface" "ca_central_1a_storage" {
  subnet_id = aws_subnet.ca_central_1a_gateway.id
}

resource "aws_subnet" "ca_central_1a_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.16.24.0/21"
  availability_zone = "ca-central-1a"
  
  tags = {
    env = "production"
    zone = "ca-central-1a"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1a_connect"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ca_central_1a_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ca-central-1a"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1a_connect"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ca_central_1a_connect" {
  subnet_id = aws_subnet.ca_central_1a_gateway.id
  route_table_id = aws_route_table.ca_central_1a_connect.id
}

resource "aws_route" "ca_central_1a_connect_compute" {
  route_table_id = aws_route_table.ca_central_1a_connect.id
  destination_cidr_block = "10.16.0.0/21"
}

resource "aws_route" "ca_central_1a_connect_outside" {
  route_table_id = aws_route_table.ca_central_1a_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ca_central_1a_connect" {
  subnet_id = aws_subnet.ca_central_1a_gateway.id
}

resource "aws_network_acl" "ca_central_1a_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ca_central_1a_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "ca-central-1a"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1a_gateway"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }
}

resource "aws_eip" "ca_central_1b_gateway" {
  vpc = true
  network_interface = aws_network_interface.ca_central_1b_gateway.id
  
  tags = {
    name = "ca_central_1b_gateway"
    env = "production"
    zone = "ca-central-1b"
    author = "Lance Pollard"
    region = "ca-central-1"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_nat_gateway" "ca_central_1b_gateway" {
  subnet_id = aws_subnet.ca_central_1b_gateway.id
  allocation_id = aws_eip.ca_central_1b_gateway.id
  
  tags = {
    name = "ca_central_1b_gateway"
    region = "ca-central-1"
    zone = "ca-central-1b"
    author = "Lance Pollard"
    env = "production"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_subnet" "ca_central_1b_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.16.32.0/21"
  availability_zone = "ca-central-1b"
  
  tags = {
    env = "production"
    zone = "ca-central-1b"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1b_gateway"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ca_central_1b_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ca-central-1b"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1b_gateway"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ca_central_1b_gateway" {
  subnet_id = aws_subnet.ca_central_1b_gateway.id
  route_table_id = aws_route_table.ca_central_1b_gateway.id
}

resource "aws_route" "ca_central_1b_gateway_compute" {
  route_table_id = aws_route_table.ca_central_1b_gateway.id
  destination_cidr_block = "10.16.24.0/21"
}

resource "aws_network_interface" "ca_central_1b_gateway" {
  subnet_id = aws_subnet.ca_central_1b_gateway.id
}

resource "aws_subnet" "ca_central_1b_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.16.24.0/21"
  availability_zone = "ca-central-1b"
  
  tags = {
    env = "production"
    zone = "ca-central-1b"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1b_compute"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ca_central_1b_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ca-central-1b"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1b_compute"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ca_central_1b_compute" {
  subnet_id = aws_subnet.ca_central_1b_gateway.id
  route_table_id = aws_route_table.ca_central_1b_compute.id
}

resource "aws_route" "ca_central_1b_compute_storage" {
  route_table_id = aws_route_table.ca_central_1b_compute.id
  destination_cidr_block = "10.16.40.0/21"
}

resource "aws_route" "ca_central_1b_compute_gateway" {
  route_table_id = aws_route_table.ca_central_1b_compute.id
  destination_cidr_block = "10.16.32.0/21"
}

resource "aws_route" "ca_central_1b_compute_connect" {
  route_table_id = aws_route_table.ca_central_1b_compute.id
  destination_cidr_block = "10.16.48.0/21"
}

resource "aws_network_interface" "ca_central_1b_compute" {
  subnet_id = aws_subnet.ca_central_1b_gateway.id
}

resource "aws_subnet" "ca_central_1b_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.16.40.0/21"
  availability_zone = "ca-central-1b"
  
  tags = {
    env = "production"
    zone = "ca-central-1b"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1b_storage"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ca_central_1b_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ca-central-1b"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1b_storage"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ca_central_1b_storage" {
  subnet_id = aws_subnet.ca_central_1b_gateway.id
  route_table_id = aws_route_table.ca_central_1b_storage.id
}

resource "aws_route" "ca_central_1b_storage_compute" {
  route_table_id = aws_route_table.ca_central_1b_storage.id
  destination_cidr_block = "10.16.24.0/21"
}

resource "aws_network_interface" "ca_central_1b_storage" {
  subnet_id = aws_subnet.ca_central_1b_gateway.id
}

resource "aws_subnet" "ca_central_1b_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.16.48.0/21"
  availability_zone = "ca-central-1b"
  
  tags = {
    env = "production"
    zone = "ca-central-1b"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1b_connect"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ca_central_1b_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ca-central-1b"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1b_connect"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ca_central_1b_connect" {
  subnet_id = aws_subnet.ca_central_1b_gateway.id
  route_table_id = aws_route_table.ca_central_1b_connect.id
}

resource "aws_route" "ca_central_1b_connect_compute" {
  route_table_id = aws_route_table.ca_central_1b_connect.id
  destination_cidr_block = "10.16.24.0/21"
}

resource "aws_route" "ca_central_1b_connect_outside" {
  route_table_id = aws_route_table.ca_central_1b_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ca_central_1b_connect" {
  subnet_id = aws_subnet.ca_central_1b_gateway.id
}

resource "aws_network_acl" "ca_central_1b_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ca_central_1b_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "ca-central-1b"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1b_gateway"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }
}

resource "aws_eip" "ca_central_1d_gateway" {
  vpc = true
  network_interface = aws_network_interface.ca_central_1d_gateway.id
  
  tags = {
    name = "ca_central_1d_gateway"
    env = "production"
    zone = "ca-central-1d"
    author = "Lance Pollard"
    region = "ca-central-1"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_nat_gateway" "ca_central_1d_gateway" {
  subnet_id = aws_subnet.ca_central_1d_gateway.id
  allocation_id = aws_eip.ca_central_1d_gateway.id
  
  tags = {
    name = "ca_central_1d_gateway"
    region = "ca-central-1"
    zone = "ca-central-1d"
    author = "Lance Pollard"
    env = "production"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_subnet" "ca_central_1d_gateway" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.16.56.0/21"
  availability_zone = "ca-central-1d"
  
  tags = {
    env = "production"
    zone = "ca-central-1d"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1d_gateway"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ca_central_1d_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ca-central-1d"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1d_gateway"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ca_central_1d_gateway" {
  subnet_id = aws_subnet.ca_central_1d_gateway.id
  route_table_id = aws_route_table.ca_central_1d_gateway.id
}

resource "aws_route" "ca_central_1d_gateway_compute" {
  route_table_id = aws_route_table.ca_central_1d_gateway.id
  destination_cidr_block = "10.16.48.0/21"
}

resource "aws_network_interface" "ca_central_1d_gateway" {
  subnet_id = aws_subnet.ca_central_1d_gateway.id
}

resource "aws_subnet" "ca_central_1d_compute" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.16.48.0/21"
  availability_zone = "ca-central-1d"
  
  tags = {
    env = "production"
    zone = "ca-central-1d"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1d_compute"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ca_central_1d_compute" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ca-central-1d"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1d_compute"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ca_central_1d_compute" {
  subnet_id = aws_subnet.ca_central_1d_gateway.id
  route_table_id = aws_route_table.ca_central_1d_compute.id
}

resource "aws_route" "ca_central_1d_compute_storage" {
  route_table_id = aws_route_table.ca_central_1d_compute.id
  destination_cidr_block = "10.16.64.0/21"
}

resource "aws_route" "ca_central_1d_compute_gateway" {
  route_table_id = aws_route_table.ca_central_1d_compute.id
  destination_cidr_block = "10.16.56.0/21"
}

resource "aws_route" "ca_central_1d_compute_connect" {
  route_table_id = aws_route_table.ca_central_1d_compute.id
  destination_cidr_block = "10.16.72.0/21"
}

resource "aws_network_interface" "ca_central_1d_compute" {
  subnet_id = aws_subnet.ca_central_1d_gateway.id
}

resource "aws_subnet" "ca_central_1d_storage" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.16.64.0/21"
  availability_zone = "ca-central-1d"
  
  tags = {
    env = "production"
    zone = "ca-central-1d"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1d_storage"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ca_central_1d_storage" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ca-central-1d"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1d_storage"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ca_central_1d_storage" {
  subnet_id = aws_subnet.ca_central_1d_gateway.id
  route_table_id = aws_route_table.ca_central_1d_storage.id
}

resource "aws_route" "ca_central_1d_storage_compute" {
  route_table_id = aws_route_table.ca_central_1d_storage.id
  destination_cidr_block = "10.16.48.0/21"
}

resource "aws_network_interface" "ca_central_1d_storage" {
  subnet_id = aws_subnet.ca_central_1d_gateway.id
}

resource "aws_subnet" "ca_central_1d_connect" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.16.72.0/21"
  availability_zone = "ca-central-1d"
  
  tags = {
    env = "production"
    zone = "ca-central-1d"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1d_connect"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table" "ca_central_1d_connect" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    env = "production"
    zone = "ca-central-1d"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1d_connect"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
}

resource "aws_route_table_association" "ca_central_1d_connect" {
  subnet_id = aws_subnet.ca_central_1d_gateway.id
  route_table_id = aws_route_table.ca_central_1d_connect.id
}

resource "aws_route" "ca_central_1d_connect_compute" {
  route_table_id = aws_route_table.ca_central_1d_connect.id
  destination_cidr_block = "10.16.48.0/21"
}

resource "aws_route" "ca_central_1d_connect_outside" {
  route_table_id = aws_route_table.ca_central_1d_connect.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_network_interface" "ca_central_1d_connect" {
  subnet_id = aws_subnet.ca_central_1d_gateway.id
}

resource "aws_network_acl" "ca_central_1d_gateway" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.ca_central_1d_gateway.id
  ]
  
  tags = {
    env = "production"
    zone = "ca-central-1d"
    author = "Lance Pollard"
    region = "ca-central-1"
    name = "ca_central_1d_gateway"
    build_version = "1.0.2"
    planned = "2020-07-31T22:25:32-07:00"
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }
  
  ingress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }
}

output "lb_arn" {
  value = aws_lb.lb.arn
}
