# AWS Resources
resource "aws_vpc" "aws_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "AWS VPC"
  }
}

resource "aws_subnet" "aws_subnet" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "AWS Subnet"
  }
}

resource "aws_internet_gateway" "aws_igw" {
  vpc_id = aws_vpc.aws_vpc.id

  tags = {
    Name = "AWS Internet Gateway"
  }
}

resource "aws_route_table" "aws_rt" {
  vpc_id = aws_vpc.aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_igw.id
  }

  tags = {
    Name = "AWS Route Table"
  }
}

resource "aws_route_table_association" "aws_rta" {
  subnet_id      = aws_subnet.aws_subnet.id
  route_table_id = aws_route_table.aws_rt.id
}

resource "aws_security_group" "aws_sg" {
  name        = "allow_ssh_and_icmp"
  description = "Allow SSH and ICMP inbound traffic"
  vpc_id      = aws_vpc.aws_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_and_icmp"
  }
}

resource "aws_instance" "aws_instance" {
  ami                         = "ami-06b21ccaeff8cd686"  # Updated Amazon Linux 2 AMI
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.aws_subnet.id
  vpc_security_group_ids      = [aws_security_group.aws_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "AWS Instance"
  }
}

# Google Cloud Resources
resource "google_compute_network" "gcp_vpc" {
  name                    = "gcp-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gcp_subnet" {
  name          = "gcp-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.gcp_vpc.id
}

resource "google_compute_firewall" "gcp_firewall" {
  name    = "allow-ssh-and-icmp"
  network = google_compute_network.gcp_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "gcp_instance" {
  name         = "gcp-instance"
  machine_type = "e2-micro"
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.gcp_vpc.name
    subnetwork = google_compute_subnetwork.gcp_subnet.name
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "pablo:${file("C:/Users/PABLO MESSIER/.ssh/google_compute_engine.pub")}"  # Replace with your SSH public key path
  }
}

# Variables
variable "aws_region" {
  default = "us-east-1"
}

variable "gcp_region" {
  default = "us-central1"
}

# Outputs
output "aws_instance_public_ip" {
  value = aws_instance.aws_instance.public_ip
}

output "gcp_instance_public_ip" {
  value = google_compute_instance.gcp_instance.network_interface[0].access_config[0].nat_ip
}