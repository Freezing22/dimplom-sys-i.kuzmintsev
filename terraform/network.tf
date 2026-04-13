resource "yandex_vpc_network" "diplom_net" {
  name = "diplom-network"
}

resource "yandex_vpc_subnet" "public_subnet_a" {
  name           = "public-subnet-a"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.diplom_net.id
  v4_cidr_blocks = ["10.10.1.0/24"]
}

resource "yandex_vpc_subnet" "private_subnet_a" {
  name           = "private-subnet-a"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.diplom_net.id
  v4_cidr_blocks = ["10.10.11.0/24"]
  route_table_id = yandex_vpc_route_table.nat_route.id
}

resource "yandex_vpc_subnet" "private_subnet_b" {
  name           = "private-subnet-b"
  zone           = var.zone_b
  network_id     = yandex_vpc_network.diplom_net.id
  v4_cidr_blocks = ["10.10.12.0/24"]
  route_table_id = yandex_vpc_route_table.nat_route.id
}

#NAT-шлюз и таблица маршрутизации для приватных подсетей 
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat_route" {
  name       = "nat-route-table"
  network_id = yandex_vpc_network.diplom_net.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

#ALB

resource "yandex_alb_target_group" "web_tg" {
  name = "web-target-group"

  target {
    ip_address = yandex_compute_instance.web1.network_interface[0].ip_address
    subnet_id  = yandex_vpc_subnet.private_subnet_a.id
  }
  target {
    ip_address = yandex_compute_instance.web2.network_interface[0].ip_address
    subnet_id  = yandex_vpc_subnet.private_subnet_b.id
  }
}

resource "yandex_alb_backend_group" "web_bg" {
  name = "web-backend-group"

  http_backend {
    name = "http-backend"
    port = 80
    target_group_ids = [yandex_alb_target_group.web_tg.id]
    healthcheck {
      timeout  = "1s"
      interval = "2s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web_router" {
  name = "web-router"
}

resource "yandex_alb_virtual_host" "web_vhost" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web_router.id
  route {
    name = "default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_bg.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web_lb" {
  name               = "web-load-balancer"
  network_id         = yandex_vpc_network.diplom_net.id
  security_group_ids = [yandex_vpc_security_group.alb_sg.id]  # Теперь alb_sg объявлен

  allocation_policy {
    location {
      zone_id   = var.zone_a
      subnet_id = yandex_vpc_subnet.public_subnet_a.id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web_router.id
      }
    }
  }
}
