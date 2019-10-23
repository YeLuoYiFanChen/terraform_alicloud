provider "alicloud" {
  access_key ="LTAI3NLUtctghprQ"
  secret_key ="RJoLjd1M9mCypkziky7alw9bqkcSBx"
  region =    "cn-qingdao"
}
resource "alicloud_vpc" "alicloud_vpc-xbacde" {
  cidr_block = "10.10.10.0/24"
}