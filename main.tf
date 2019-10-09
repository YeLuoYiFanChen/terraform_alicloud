provider "alicloud" {
  access_key ="LTAI3NLUtctghprQ"
  secret_key ="RJoLjd1M9mCypkziky7alw9bqkcSBx"
  region =    "cn-qingdao"
}
resource "alicloud_vpc" "alicloud_vpc-xbacde" {
  cidr_block = "10.10.10.0/24"
}
resource "alicloud_security_group" "alicloud_security_group-xxxabc" {
  name        = "default"
  vpc_id      = "${alicloud_vpc.alicloud_vpc-xbacde.id}"
  description = "默认安全组"
}
resource "alicloud_vswitch" "alicloud_vswitch-abcdqlf" {
  cidr_block        = "10.10.10.0/24"
  vpc_id            = "${alicloud_vpc.alicloud_vpc-xbacde.id}"
  availability_zone = "cn-qingdao-c"
}
resource "alicloud_nat_gateway" "alicloud_nat_gateway-Xab31" {
  vpc_id        = "${alicloud_vpc.alicloud_vpc-xbacde.id}"
  specification = "Small"
}
resource "alicloud_instance" "alicloud_instance-abv2fsX" {
  image_id             = "ubuntu_18_04_64_20G_alibase_20190509.vhd"
  instance_type        = "ecs.t5-lc1m1.small"
  instance_charge_type = "PostPaid"
  instance_name        = "webserver"
  key_name             = "${alicloud_key_pair.alicloud_key_pair-ab2xx.id}"
  internet_charge_type = "PayByTraffic"
  system_disk_category = "cloud_efficiency"
  security_groups      = ["${alicloud_security_group.alicloud_security_group-xxxabc.id}"]
  vswitch_id           = "${alicloud_vswitch.alicloud_vswitch-abcdqlf.id}"
}
resource "alicloud_key_pair" "alicloud_key_pair-ab2xx" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDRelVOErDdAhUF76uuKRH1Po8fPEBFUO6bCpBR6KCcLgweHYSSzGOTCpCfynoAikhqnP8hVabJqza6XKBofHt+HdoBlRHB+5On+Qv01Spm7WB2kvbET7Ce23eBebspjcAeZKvLayDdX3udA6gRO+kvpVtddydbUIgWfRQVRws7Uaj2mcgdS9o4nObdzm11zxs6DMhmHXl7twKpndS5gkCpZZvAje6e/JBweNgas9bkme3JeiYsmJ2yvPMl6AQRZL9eIjBi7ErBVgLopUiAUEvQYXAKkeTZlpEVTFGng+NOeNR5FMpU1impdLlbWAXC8R6QJIt3QG3qL0P0BeLSnON"
}
resource "alicloud_security_group_rule" "alicloud_security_group-xxxabc_ingress_rule" {
  ip_protocol       = "all"
  nic_type          = "intranet"
  port_range        = "-1/-1"
  priority          = 1
  type              = "ingress"
  security_group_id = "${alicloud_security_group.alicloud_security_group-xxxabc.id}"
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}
resource "alicloud_security_group_rule" "alicloud_security_group-xxxabc_egress_rule" {
  priority          = 1
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
  type              = "egress"
  security_group_id = "${alicloud_security_group.alicloud_security_group-xxxabc.id}"
  ip_protocol       = "all"
  nic_type          = "intranet"
  port_range        = "-1/-1"
}
resource "alicloud_eip" "alicloud_nat_gateway-Xab31_snat_eip" {
}
resource "alicloud_eip_association" "alicloud_nat_gateway-Xab31_snat_association" {
  allocation_id = "${alicloud_eip.alicloud_nat_gateway-Xab31_snat_eip.id}"
  instance_id   = "${alicloud_nat_gateway.alicloud_nat_gateway-Xab31.id}"
}
resource "alicloud_snat_entry" "alicloud_nat_gateway-Xab31_snat_entry" {
  source_vswitch_id = "${alicloud_vswitch.alicloud_vswitch-abcdqlf.id}"
  snat_table_id     = "${alicloud_nat_gateway.alicloud_nat_gateway-Xab31.snat_table_ids}"
  snat_ip           = "${alicloud_eip.alicloud_nat_gateway-Xab31_snat_eip.ip_address}"
}
resource "alicloud_eip" "alicloud_nat_gateway-Xab31_dnat_eip" {
}
resource "alicloud_eip_association" "alicloud_nat_gateway-Xab31_dnat_association" {
  instance_id   = "${alicloud_nat_gateway.alicloud_nat_gateway-Xab31.id}"
  allocation_id = "${alicloud_eip.alicloud_nat_gateway-Xab31_dnat_eip.id}"
}
resource "alicloud_forward_entry" "alicloud_nat_gateway-Xab31_dnat_entry" {
  internal_ip      = "${alicloud_instance.alicloud_instance-abv2fsX.private_ip}"
  internal_port    = 22
  forward_table_id = "${alicloud_nat_gateway.alicloud_nat_gateway-Xab31.forward_table_ids}"
  external_ip      = "${alicloud_eip.alicloud_nat_gateway-Xab31_dnat_eip.ip_address}"
  external_port    = 22
  ip_protocol      = "tcp"
}