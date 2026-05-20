
# Establishing the Peering b/w the App and Monitoring VPC's
resource "aws_vpc_peering_connection" "this" {
  vpc_id      = module.vpc-app.vpc_id
  peer_vpc_id = module.vpc-monitoring.vpc_id
  auto_accept = true

  tags = {
    Name = "app-monitoring-peering"
  }
}

# Add the routes in public and private route tables of vpc-app
resource "aws_route" "app-to-monitoring-priv" {
  count                     = length(module.vpc-app.private_route_table_ids)
  route_table_id            = module.vpc-app.private_route_table_ids[count.index]
  destination_cidr_block    = module.vpc-monitoring.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "app-to-monitoring-pub" {
  count                     = length(module.vpc-app.public_route_table_ids)
  route_table_id            = module.vpc-app.public_route_table_ids[count.index]
  destination_cidr_block    = module.vpc-monitoring.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# Add the routes in public and private route tables of vpc-monitoring
resource "aws_route" "monitoring-to-app-priv" {
  count                     = length(module.vpc-monitoring.private_route_table_ids)
  route_table_id            = module.vpc-monitoring.private_route_table_ids[count.index]
  destination_cidr_block    = module.vpc-app.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "monitoring-to-app-pub" {
  count                     = length(module.vpc-monitoring.public_route_table_ids)
  route_table_id            = module.vpc-monitoring.public_route_table_ids[count.index]
  destination_cidr_block    = module.vpc-app.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

