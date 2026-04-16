locals {
  # /16 VPC CIDR 을 AZ 수만큼 /24 public subnet 으로 잘라서
  # "AZ 이름 -> subnet CIDR" 형태의 map 으로 만든다.
  public_subnet_map = {
    for index, az in var.azs :
    az => cidrsubnet(var.vpc_cidr, 8, index)
  }

  # private subnet 은 public subnet 과 CIDR 이 겹치지 않도록
  # offset 을 주어 뒤쪽 대역에서 별도로 만든다.
  private_subnet_map = {
    for index, az in var.azs :
    az => cidrsubnet(var.vpc_cidr, 8, index + 10)
  }

  # NAT Gateway 는 특정 AZ 의 public subnet 안에 생성되어야 한다.
  # 1차 포트폴리오 버전은 비용 절감을 위해 단일 NAT 만 두고,
  # 첫 번째 AZ 의 public subnet 에 배치한다.
  nat_gateway_az = var.azs[0]
}

resource "aws_vpc" "this" {
  # EKS 와 관련 네트워크 리소스를 담는 전용 사설 네트워크
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = "${var.name}-vpc"
  })
}

# Internet Gateway 는 subnet 이 아니라 VPC 에 연결된다.
# public route table 이 이 IGW 를 기본 경로로 사용할 때
# 해당 subnet 이 인터넷 직결 subnet 처럼 동작한다.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.name}-igw"
  })
}

resource "aws_subnet" "public" {
  # ALB, NAT Gateway 처럼 외부 인터넷과 직접 연결되는 리소스가 들어갈 public subnet
  for_each = local.public_subnet_map

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.name}-public-${each.key}"
    # 이 subnet 이 현재 EKS 클러스터에서 사용 가능한 subnet 임을 표시
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # AWS Load Balancer Controller 가 internet-facing ELB/ALB 생성 시 사용할 public subnet 임을 표시
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "private" {
  # 실제 worker node 와 내부 workload 가 들어갈 private subnet
  for_each = local.private_subnet_map

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name                                        = "${var.name}-private-${each.key}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # internal load balancer 가 배치될 수 있는 private subnet 임을 표시
    "kubernetes.io/role/internal-elb" = "1"
  })
}

# public subnet 용 route table.
# 0.0.0.0/0 을 IGW 로 보내는 규칙과 함께 연결되면
# 이 route table 을 쓰는 subnet 들이 public subnet 역할을 하게 된다.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.name}-public"
  })
}

# public subnet 의 기본 인터넷 경로
resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# 각 public subnet 을 public route table 에 연결
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  # NAT Gateway 가 외부 인터넷과 통신할 때 사용할 고정 public IP
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.name}-nat"
  })
}

resource "aws_nat_gateway" "this" {
  # private subnet 에 있는 리소스가 외부로만 나갈 수 있게 해주는 중계기.
  # NAT 자체는 public subnet 안에 있어야 한다.
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[local.nat_gateway_az].id

  tags = merge(var.common_tags, {
    Name = "${var.name}-nat"
  })

  depends_on = [aws_internet_gateway.this]
}

# private subnet 용 route table.
# 외부 인터넷으로의 기본 경로는 IGW 가 아니라 NAT Gateway 를 사용한다.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.name}-private"
  })
}

# private subnet 의 기본 outbound 경로
resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

# 각 private subnet 을 private route table 에 연결
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
