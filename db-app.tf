resource "aws_db_instance" "default" {

  db_name                   = var.dbname
  engine                 = "mysql"
  option_group_name      = aws_db_option_group.default.name
  parameter_group_name   = aws_db_parameter_group.default.name
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  identifier              = "rds-315040492946-acme-dev"
  engine_version          = "8.0" # Latest major version 
  instance_class          = "db.t3.micro"
  allocated_storage       = "20"
  username                = "admin"
  password                = var.password
  apply_immediately       = true
  multi_az                = false
  backup_retention_period = 0
  storage_encrypted       = false
  skip_final_snapshot     = true
  monitoring_interval     = 0
  publicly_accessible     = true

  # Ignore password changes from tf plan diff
  lifecycle {
    ignore_changes = ["password"]
  }
}

resource "aws_db_option_group" "default" {
  engine_name              = "mysql"
  name                     = "og-315040492946-acme-dev"
  major_engine_version     = "8.0"
  option_group_description = "Terraform OG"
}

resource "aws_db_parameter_group" "default" {
  name        = "pg-315040492946-acme-dev"
  family      = "mysql8.0"
  description = "Terraform PG"

  parameter {
    name         = "character_set_client"
    value        = "utf8"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_server"
    value        = "utf8"
    apply_method = "immediate"
  }
}

resource "aws_db_subnet_group" "default" {
  name        = "sg-315040492946-acme-dev"
  subnet_ids  = ["${aws_subnet.web_subnet.id}", "${aws_subnet.web_subnet2.id}"]
  description = "Terraform DB Subnet Group"
}

resource "aws_security_group" "default" {
  name   = "315040492946-acme-dev-rds-sg"
  vpc_id = aws_vpc.web_vpc.id
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = "3306"
  to_port           = "3306"
  protocol          = "tcp"
  cidr_blocks       = ["${aws_vpc.web_vpc.cidr_block}"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.default.id}"
}


### EC2 instance 
resource "aws_iam_instance_profile" "ec2profile" {
  name = "315040492946-acme-dev-profile"
  role = "${aws_iam_role.ec2role.name}"
}

resource "aws_iam_role" "ec2role" {
  name = "315040492946-acme-dev-role"
  path = "/"

  assume_role_policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOT
}

resource "aws_iam_role_policy" "ec2policy" {
  name = "315040492946-acme-dev-policy"
  role = aws_iam_role.ec2role.id

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "ec2:*",
        "rds:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOT
}

output "db_endpoint" {
  description = "DB Endpoint"
  value       = aws_db_instance.default.endpoint
}

