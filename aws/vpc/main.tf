###
# VPC
###
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.application}-${var.environment}"
  }
}


###
# Subnets
###
resource "aws_subnet" "public" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.application}-${var.environment}-public-${count.index}"
  }
}

resource "aws_subnet" "private_dbs" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.dbs_private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.application}-${var.environment}-private-dbs-${count.index}"
  }
}


###
# Internet Gateway
###

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

###
# Route tables configuration
###

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.application}-${var.environment} public"
  }
}

resource "aws_default_route_table" "r" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "${var.application}-${var.environment} main"
  }
}

resource "aws_route_table_association" "a" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.r.id
}

resource "aws_route_table_association" "private_dbs" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.private_dbs.*.id[count.index]
  route_table_id = aws_default_route_table.r.id
}


###
# Private subnet NACL configuration
###

resource "aws_network_acl" "private_dbs_subnet" {
  vpc_id = aws_vpc.main.id

  subnet_ids = aws_subnet.private_dbs.*.id

  tags = {
    Name = "private-dbs-subnet"
  }
}

resource "aws_network_acl_rule" "private_dbs_public_subnet_ingress" {
  network_acl_id = aws_network_acl.private_dbs_subnet.id
  egress         = false
  count          = length(var.azs)
  protocol       = "tcp"
  rule_number    = "11${count.index}"
  rule_action    = "allow"
  cidr_block     = aws_subnet.public.*.cidr_block[count.index]
  from_port      = var.db_port
  to_port        = var.db_port
}

resource "aws_network_acl_rule" "private_dbs_public_return_traffic" {
  network_acl_id = aws_network_acl.private_dbs_subnet.id
  egress         = true
  count          = length(var.azs)
  protocol       = "tcp"
  rule_number    = "13${count.index}"
  rule_action    = "allow"
  cidr_block     = aws_subnet.public.*.cidr_block[count.index]
  from_port      = 1024
  to_port        = 65535
}


###
# Public subnet NACL configuration
###

resource "aws_network_acl" "public_subnet" {
  vpc_id = aws_vpc.main.id

  subnet_ids = aws_subnet.public.*.id

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_network_acl_rule" "public_subnet_http_ingress" {
  network_acl_id = aws_network_acl.public_subnet.id
  egress         = false
  protocol       = "tcp"
  rule_number    = "100"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_subnet_https_ingress" {
  network_acl_id = aws_network_acl.public_subnet.id
  egress         = false
  protocol       = "tcp"
  rule_number    = "110"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_subnet_return_traffic_ingress" {
  network_acl_id = aws_network_acl.public_subnet.id
  egress         = false
  protocol       = "tcp"
  rule_number    = "120"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_subnet_ssh_ingress" {
  network_acl_id = aws_network_acl.public_subnet.id
  egress         = false
  protocol       = "tcp"
  rule_number    = "130"
  rule_action    = "allow"
  cidr_block     = var.ssh_cidr
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_subnet_http_egress" {
  network_acl_id = aws_network_acl.public_subnet.id
  egress         = true
  protocol       = "tcp"
  rule_number    = "100"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_subnet_https_egress" {
  network_acl_id = aws_network_acl.public_subnet.id
  egress         = true
  protocol       = "tcp"
  rule_number    = "110"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_subnet_return_traffic_egress" {
  network_acl_id = aws_network_acl.public_subnet.id
  egress         = true
  protocol       = "tcp"
  rule_number    = "120"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_subnet_private_dbs_egress" {
  count          = length(var.azs)
  network_acl_id = aws_network_acl.public_subnet.id
  egress         = true
  protocol       = "tcp"
  rule_number    = "15${count.index}"
  rule_action    = "allow"
  cidr_block     = aws_subnet.private_dbs.*.cidr_block[count.index]
  from_port      = var.db_port
  to_port        = var.db_port
}

###
# Default security group
###

resource "aws_default_security_group" "sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.application}-${var.environment}"
  }
}

###
# Custom security groups
###
resource "aws_security_group" "servers" {
  name   = "${var.application}-${var.environment}-server-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a security group for the database and allow access from server server
resource "aws_security_group" "dbs" {
  name   = "${var.application}-db-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.servers.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.servers.id]
  }
}
