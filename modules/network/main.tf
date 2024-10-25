# 1. Crear VPC: para contener todos los recursos de red, como subnets, tablas de rutas y gateways.
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" # Rango de IPs privado para la VPC
  enable_dns_support   = true          # Habilitar soporte de DNS
  enable_dns_hostnames = true          # Habilitar nombres de host DNS para los recursos

  tags = {
    Name = "my-vpc"
  }
}

# 2. Crear Internet Gateway: para permitir el tráfico de internet en la subred pública.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id # Asociar el Internet Gateway a la VPC

  tags = {
    Name = "my-igw"
  }
}

# 3. Crear Subnets Públicas: estas subnets estarán accesibles desde internet, principalmente para alojar el NLB.
resource "aws_subnet" "public" {
  count                   = 2 # Definir dos subnets públicas en diferentes zonas de disponibilidad
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index) # Dividir el CIDR de la VPC
  map_public_ip_on_launch = true                                                # Asignar una IP pública automáticamente a las instancias en esta subnet
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# 4. Crear Subnets Privadas: estas subnets no estarán accesibles desde internet, donde las tareas de ECS se ejecutarán de manera segura.
resource "aws_subnet" "private" {
  count             = 2 # Definir dos subnets privadas en diferentes zonas de disponibilidad
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 100) # Dividir el CIDR de la VPC para subnets privadas
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# 5. Crear un NAT Gateway: para permitir que las tareas en las subnets privadas accedan a internet sin ser accesibles directamente desde internet.
resource "aws_eip" "nat_eip" {
  count  = 1
  domain = "vpc" # Indica que el EIP está asociado a la VPC
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip[0].id   # Asignar la Elastic IP al NAT Gateway
  subnet_id     = aws_subnet.public[0].id # Colocar el NAT Gateway en la subnet pública

  tags = {
    Name = "my-nat-gateway"
  }
}

# 6. Crear tabla de rutas públicas: para que las subnets públicas tengan acceso a internet.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id # Asociar la tabla de rutas a la VPC

  # Definir la ruta predeterminada para el tráfico de internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id # Usar el Internet Gateway para las rutas públicas
  }

  tags = {
    Name = "public-route-table"
  }
}

# 7. Asociar la tabla de rutas públicas con las subnets públicas: asegurarse de que las subnets públicas usen la tabla de rutas públicas.
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public) # Asociar con cada subnet pública
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 8. Crear tabla de rutas privadas: para que las subnets privadas usen el NAT Gateway para acceder a internet de manera segura.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id # Asociar la tabla de rutas a la VPC

  # Definir la ruta predeterminada para el tráfico de internet saliente
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id # Usar el NAT Gateway para las subnets privadas
  }

  tags = {
    Name = "private-route-table"
  }
}

# 9. Asociar la tabla de rutas privadas con las subnets privadas: asegurarse de que las subnets privadas usen la tabla de rutas privadas.
resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private) # Asociar con cada subnet privada
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
