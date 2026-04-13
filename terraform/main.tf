terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.129.0"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  service_account_key_file = pathexpand(var.service_account_key_file)
}

data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}


resource "local_file" "inventory" {
  content = <<-EOF
    [bastions]
    bastion ansible_host=${yandex_compute_instance.bastion.network_interface[0].nat_ip_address}

    [webservers]
    web1 ansible_host=${yandex_compute_instance.web1.fqdn}
    web2 ansible_host=${yandex_compute_instance.web2.fqdn}

    [elasticsearch]
    elastic ansible_host=${yandex_compute_instance.elastic.fqdn}

    [monitoring]
    zabbix ansible_host=${yandex_compute_instance.zabbix.fqdn}

    [kibana_server]
    kibana ansible_host=${yandex_compute_instance.kibana.fqdn}

    [all:vars]
    ansible_user=ubuntu
    ansible_ssh_private_key_file=~/.ssh/id_ed25519
    ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q ubuntu@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
  EOF

  filename = "${path.module}/../ansible/hosts.ini"
}