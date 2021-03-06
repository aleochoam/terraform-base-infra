resource "aws_db_subnet_group" "default" {
  name       = "${var.application}-${var.environment}"
  subnet_ids = var.subnets
}

resource "aws_db_instance" "default" {
  allocated_storage       = var.allocated_storage
  storage_type            = "gp2"
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_type
  name                    = var.db_name
  username                = var.username
  password                = var.password
  availability_zone       = var.azs[0]
  db_subnet_group_name    = aws_db_subnet_group.default.id
  vpc_security_group_ids  = [var.security_group]
  skip_final_snapshot     = true
  identifier              = "${var.application}-${var.environment}"
  backup_retention_period = var.backup_retention_period
  apply_immediately       = true
  multi_az                = var.multi_az
}
