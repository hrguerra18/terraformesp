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

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir acceso MySQL desde cualquier lugar (puedes restringir esto más adelante)
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
  user_data       = file("command2.sh")
  
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

# Crear el balanceador de carga
resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false
  tags = {
    Name = "AppLoadBalancer"
  }
}

# Crear un grupo de destinos para las instancias
resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
  tags = {
    Name = "AppTargetGroup"
  }
}

# Registrar instancias EC2 en el grupo de destinos
resource "aws_lb_target_group_attachment" "public_instance_1_attach" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.public_instance_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "public_instance_2_attach" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.public_instance_2.id
  port             = 80
}

# Crear un listener para el balanceador de carga
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Crear el grupo de subredes para la base de datos
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id] # Usar las subredes privadas

  tags = {
    Name = "MyDBSubnetGroup"
  }
}

# Crear la base de datos RDS
resource "aws_db_instance" "my_database" {
   allocated_storage    = 20  # Tamaño del almacenamiento en GB, dentro del límite gratuito
  storage_type       = "gp2"
  engine             = "mysql" 
  engine_version     = "8.0.39"  
  instance_class     = "db.t3.micro" # Asegúrate de usar una instancia elegible para la capa gratuita
  db_name            = "dbesp2" 
  username           = "admin"
  password           = "admin123" 
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.public_sg.id] 
  db_subnet_group_name    = aws_db_subnet_group.my_db_subnet_group.name

  tags = {
    Name = "MyRDSInstance"
  }
}

# Crear una tabla de DynamoDB
resource "aws_dynamodb_table" "http_crud_tutorial_items" {
  name         = "http-crud-tutorial-items-tf"
  billing_mode = "PAY_PER_REQUEST"  # Modo de facturación a demanda

  hash_key     = "id"  # Clave de partición

  attribute {
    name = "id"
    type = "S"  # Tipo de atributo (S = String)
  }

  tags = {
    Name = "HTTPCrudTutorialItems-tf"
  }
}

# Salida opcional para ver el nombre de la tabla creada
output "dynamodb_table_name" {
  value = aws_dynamodb_table.http_crud_tutorial_items.name
}

# Crear un único rol de IAM para la función Lambda
resource "aws_iam_role" "lambda_role-tf" {
  name = "lambda-role-tf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "LambdaRole-tf"
  }
}

# Política de permisos para DynamoDB y CloudWatch Logs
resource "aws_iam_policy" "lambda_dynamodb_policy-tf" {
  name = "lambda-dynamodb-policy-tf"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.http_crud_tutorial_items.arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "LambdaDynamoDBPolicy-tf"
  }
}

# Adjuntar la política y los permisos de ejecución básica al rol
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment-tf" {
  role       = aws_iam_role.lambda_role-tf.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy-tf.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution-tf" {
  role       = aws_iam_role.lambda_role-tf.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_lambda_function" "http_crud_lambda-tf" {
  function_name = "http-crud-lambda-tf"
  role          = aws_iam_role.lambda_role-tf.arn  
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = "lambda_function.zip"  # Asegúrate de que este archivo esté cargado
  
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.http_crud_tutorial_items.name
    }
  }

  tags = {
    Name = "HTTPCrudLambdaFunction-tf"
  }
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.http_crud_tutorial_items.arn
}

# Output opcional de la función Lambda ARN
output "lambda_function_arn" {
  value = aws_lambda_function.http_crud_lambda-tf.arn
}

# Crear API HTTP en API Gateway
resource "aws_apigatewayv2_api" "http_crud_api-tf" {
  name          = "http-crud-tutorial-api-tf"
  protocol_type = "HTTP"
}

# Crear la integración de API Gateway con la función Lambda
resource "aws_apigatewayv2_integration" "lambda_integration-tf" {
  api_id             = aws_apigatewayv2_api.http_crud_api-tf.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.http_crud_lambda-tf.invoke_arn
  payload_format_version = "2.0"
}

# Crear ruta para GET /items/{id}
resource "aws_apigatewayv2_route" "get_item_route-tf" {
  api_id    = aws_apigatewayv2_api.http_crud_api-tf.id
  route_key = "GET /items/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration-tf.id}"
}

# Crear ruta para PUT /items
resource "aws_apigatewayv2_route" "put_item_route-tf" {
  api_id    = aws_apigatewayv2_api.http_crud_api-tf.id
  route_key = "PUT /items"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration-tf.id}"
}

# Crear ruta para DELETE /items/{id}
resource "aws_apigatewayv2_route" "delete_item_route-tf" {
  api_id    = aws_apigatewayv2_api.http_crud_api-tf.id
  route_key = "DELETE /items/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration-tf.id}"
}

# Crear ruta para GET /items
resource "aws_apigatewayv2_route" "get_items_route-tf" {
  api_id    = aws_apigatewayv2_api.http_crud_api-tf.id
  route_key = "GET /items"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration-tf.id}"
}


# Crear un deployment de API
resource "aws_apigatewayv2_stage" "default_stage-tf" {
  api_id = aws_apigatewayv2_api.http_crud_api-tf.id
  name   = "$default"
  auto_deploy = true
}

# Permisos para que API Gateway invoque la Lambda
resource "aws_lambda_permission" "apigw-lambda-tf" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.http_crud_lambda-tf.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_crud_api-tf.execution_arn}/*"
}



