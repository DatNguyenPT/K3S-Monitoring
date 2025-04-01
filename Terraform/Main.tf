variable "key_name" {
  default = "ssh-key"
}
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
# Create a VPC
resource "aws_vpc" "k3s_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    name = "K3s_VPC"
  }
}

# Create network ACL
resource "aws_default_network_acl" "default_k3s_vpc_acl" {
  default_network_acl_id = aws_vpc.k3s_vpc.default_network_acl_id
  ingress {
    protocol = -1
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  egress {
    protocol = -1
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  tags = {
    "name" = "Default_K3S_VPC_ACL"
  }
}

# Create security group
resource "aws_default_security_group" "default_k3s_vpc_sg" {
  vpc_id = aws_vpc.k3s_vpc.id

  ingress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "name" = "Default_K3S_VPC_SG"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "k3s_vpc_igw" {
  vpc_id = aws_vpc.k3s_vpc.id
  
  tags = {
    name = "K3S_VPC_IGW"
  }
}

# Create route table
resource "aws_default_route_table" "default_k3s_vpc_rt" {
  default_route_table_id = aws_vpc.k3s_vpc.default_route_table_id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k3s_vpc_igw.id
  }

  tags = {
    name = "Default_K3S_VPC_Route_Table"
  }
}

# Create a Subnet
resource "aws_subnet" "k3s_subnet_a" {
  vpc_id            = aws_vpc.k3s_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    name = "K3S_VPC_Subnet_A"
  }
}


# Master Node Key
resource "tls_private_key" "master_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "master" {
  key_name   = "${var.key_name}-master"
  public_key = tls_private_key.master_key.public_key_openssh
}

resource "local_file" "master-key" {
  filename = "${aws_key_pair.master.key_name}.pem"
  content  = tls_private_key.master_key.private_key_pem
}

# Worker Node Keys
resource "tls_private_key" "worker_keys" {
  count     = 2
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "workers" {
  count     = 2
  key_name  = "${var.key_name}-worker-${count.index + 1}"
  public_key = tls_private_key.worker_keys[count.index].public_key_openssh
}

resource "local_file" "worker-keys" {
  count    = 2
  filename = "${aws_key_pair.workers[count.index].key_name}.pem"
  content  = tls_private_key.worker_keys[count.index].private_key_pem
}



# EC2 Master Node
resource "aws_instance" "k3s_master" {
  ami                    = "ami-0866a3c8686eaeeba" 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.k3s_subnet_a.id
  vpc_security_group_ids = [aws_default_security_group.default_k3s_vpc_sg.id]
  key_name               = aws_key_pair.master.key_name
  user_data              = file("/BashScript/MasterAccount.sh")
  tenancy                = "default"

  tags = {
    Name = "K3S_Master"
  }
}

# EC2 Worker Nodes
resource "aws_instance" "k3s_worker" {
  count                  = 2
  ami                    = "ami-0866a3c8686eaeeba" 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.k3s_subnet_a.id
  vpc_security_group_ids = [aws_default_security_group.default_k3s_vpc_sg.id]  
  key_name               = aws_key_pair.workers[count.index].key_name

  # Set user_data based on the count.index value
  user_data              = file("/BashScript/Worker${count.index + 1}Account.sh")
  
  tags = {
    Name = "K3sWorker-${count.index + 1}"
  }
}

# Create elastic ip
resource "aws_eip" "k3s_master_eip" {
  instance = aws_instance.k3s_master.id
}

resource "aws_eip" "k3s_worker_eip" {
  count = 2
  instance = aws_instance.k3s_worker[count.index].id
}

# Associate the Elastic IP to the instance
resource "aws_eip_association" "master_eip_association" {
  instance_id   = aws_instance.k3s_master.id
  allocation_id = aws_eip.k3s_master_eip.id
}

resource "aws_eip_association" "workers_eip_association" {
  count = 2
  instance_id   = aws_instance.k3s_worker[count.index].id
  allocation_id = aws_eip.k3s_worker_eip[count.index].id
}

# Output for Master Node's Private Key
output "master_private_key" {
  value     = tls_private_key.master_key.private_key_pem
  sensitive = true
} 

# Outputs for Worker Keys
output "worker_private_keys" {
  value     = [for key in tls_private_key.worker_keys : key.private_key_pem]
  sensitive = true
}
