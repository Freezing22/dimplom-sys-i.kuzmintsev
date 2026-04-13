# --- Виртуальные машины ---
# Бастион-хост (публичный)
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = var.zone_a

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

scheduling_policy { preemptible = true }

  network_interface {
    subnet_id      = yandex_vpc_subnet.public_subnet_a.id
    nat            = true
    security_group_ids = [yandex_vpc_security_group.bastion_sg.id, yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.zabbix_agent_sg.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

}

# Веб-сервер 1 (приватный, зона A)
resource "yandex_compute_instance" "web1" {
  name        = "web1"
  hostname    = "web1"
  platform_id = "standard-v3"
  zone        = var.zone_a

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id      = yandex_vpc_subnet.private_subnet_a.id
    security_group_ids = [yandex_vpc_security_group.web_sg.id, yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.zabbix_agent_sg.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

}

# Веб-сервер 2 (приватный, зона B)
resource "yandex_compute_instance" "web2" {
  name        = "web2"
  hostname    = "web2"
  platform_id = "standard-v3"
  zone        = var.zone_b

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id      = yandex_vpc_subnet.private_subnet_b.id
    security_group_ids = [yandex_vpc_security_group.web_sg.id, yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.zabbix_agent_sg.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

}

# Zabbix Server (публичный)
resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix"
  hostname    = "zabbix"
  platform_id = "standard-v3"
  zone        = var.zone_a

  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id      = yandex_vpc_subnet.public_subnet_a.id
    nat            = true
    security_group_ids = [yandex_vpc_security_group.zabbix_sg.id, yandex_vpc_security_group.LAN.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }
}

# Elasticsearch (приватный)
resource "yandex_compute_instance" "elastic" {
  name        = "elastic"
  hostname    = "elastic"
  platform_id = "standard-v3"
  zone        = var.zone_a

  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id      = yandex_vpc_subnet.private_subnet_a.id
    security_group_ids = [yandex_vpc_security_group.elastic_sg.id, yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.zabbix_agent_sg.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }
}

# Kibana (публичный)
resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana"
  platform_id = "standard-v3"
  zone        = var.zone_a

  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id      = yandex_vpc_subnet.public_subnet_a.id
    nat            = true
    security_group_ids = [yandex_vpc_security_group.kibana_sg.id, yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.zabbix_agent_sg.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
 }

}