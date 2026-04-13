output "bastion_public_ip" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "web_lb_public_ip" {
  value = yandex_alb_load_balancer.web_lb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "zabbix_public_ip" {
  value = yandex_compute_instance.zabbix.network_interface[0].nat_ip_address
}

output "kibana_public_ip" {
  value = yandex_compute_instance.kibana.network_interface[0].nat_ip_address
}

output "web1_private_ip" {
  value = yandex_compute_instance.web1.network_interface[0].ip_address
}

output "web2_private_ip" {
  value = yandex_compute_instance.web2.network_interface[0].ip_address
}

output "elastic_private_ip" {
  value = yandex_compute_instance.elastic.network_interface[0].ip_address
}