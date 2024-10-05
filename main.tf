# Definir el proveedor de AWS
# provider "aws" {
#   region = "us-east-1" # Cambia la región según tus necesidades
# }

# Crear una VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "30.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

# Crear una Internet Gateway para acceso a Internet desde las subredes públicas
resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

# Crear una tabla de rutas para las subredes públicas
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Crear subredes públicas
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "30.0.1.0/24"
  availability_zone = "us-east-2a" # Cambia la zona según tus necesidades

  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "30.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "PublicSubnet2"
  }
}

# Asociar las subredes públicas con la tabla de rutas pública
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Crear subredes privadas
resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "30.0.3.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "30.0.4.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "PrivateSubnet2"
  }
}

# Crear una tabla de rutas para las subredes privadas (sin acceso directo a Internet)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "PrivateRouteTable"
  }
}

# Asociar las subredes privadas con la tabla de rutas privada
resource "aws_route_table_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_assoc" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Salida opcional de la ID de la VPC y las subredes
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnets" {
  value = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

output "private_subnets" {
  value = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

# Crear un par de llaves para acceder a las instancias EC2
resource "aws_key_pair" "main_key" {
  key_name   = "hrkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOZ/0NE10bnNWL+W8Jb5aJDlIM85uNQlxaQP4yqTc4477DWUnpQaPq9HhYXiZZXFUXyHonQtExcleqkD64Kzzy4lDoroRbV2pTdXCodSt5KC5NRnOaevu6CzEH0/WpNNX3VBy3OCEVDzqjkbrIqF1KwveLyq6fHp0sUFD675HJQaoNoH5fud/8v5GbFcCytHuWSWEjG/pcYo7/ArjLs7tLyeRi8V68HZ7zvVS3Hk6k9rkBRGdTMAClcwlwraOcBJ8pJwQTizez8e0GgApcbCJOp1eOChmgQMfGBsraguTTHAHz4URAixzQH4nJl3+lKUFh0KQlEKuGrsEI71jzH08SpXVB7N5N7fcvuhP9v9q8freff10nXRcG+tM+WYMZSV/18BEpj+bd6tQu/qKcFTxBSaI2I4jqD9N49b7dL+xMcqX2aPRUyc757zZ93qzn+cfZZWamLrQeeojLbnVESQ5LTfPAVJ3853Rxn//PD/V3tbCf0zauHhwqjNrok2FU+OnGaY5hUnRaeKpXfg3TImNiqc1M3MTZbYnY6//I8eBRon8tlLvr+sssEfpu1KTYVx4pLCsOQeFbBuT+eZf9TyLe15X3Era+zznonTWSGRSaYzkW+IPyUAwnSkPZXOU8aOtVR9jmsY/VKht1XHm9JcH9LzXKOQH8ncWregXG5vjYqQ== helderguerra18@gmail.com" # Tu clave pública SSH
}

# Security Group para permitir acceso SSH y HTTP a las instancias
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir acceso SSH desde cualquier lugar
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir tráfico HTTP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PublicSecurityGroup"
  }
}

# Crear una instancia EC2 en la primera subred pública
resource "aws_instance" "public_instance_1" {
  ami             = "ami-09da212cf18033880"  
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet_1.id
  key_name        = aws_key_pair.main_key.key_name
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  user_data       = file("command.sh")
  
  tags = {
    Name = "PublicInstance1"
  }
}

# Crear una instancia EC2 en la segunda subred pública
resource "aws_instance" "public_instance_2" {
  ami             = "ami-09da212cf18033880" 
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet_2.id
  key_name        = aws_key_pair.main_key.key_name
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  user_data       = file("command.sh")

  tags = {
    Name = "PublicInstance2"
  }
}

# Salida opcional de las direcciones IP públicas de las instancias EC2
output "public_instance_1_ip" {
  value = aws_instance.public_instance_1.public_ip
}

output "public_instance_2_ip" {
  value = aws_instance.public_instance_2.public_ip
}