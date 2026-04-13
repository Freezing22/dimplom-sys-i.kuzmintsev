# Бастион для SSH доступа
resource "yandex_vpc_security_group" "bastion_sg" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.diplom_net.id

  ingress {
    description    = "SSH from internet"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Внутренняя сеть - полный доступ между всеми хостами
resource "yandex_vpc_security_group" "LAN" {
  name       = "lan-sg"
  network_id = yandex_vpc_network.diplom_net.id

  ingress {
    description    = "Allow all from internal network"
    protocol       = "ANY"
    v4_cidr_blocks = ["10.0.0.0/8"]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    description    = "Allow all outgoing"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

#ALB 
resource "yandex_vpc_security_group" "alb_sg" {
  name        = "alb-sg"
  network_id  = yandex_vpc_network.diplom_net.id
  description = "Security group for Application Load Balancer"

  ingress {
    description    = "Allow HTTP from internet"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Yandex ALB health checks"
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    description    = "Allow all outgoing traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ZABBIX СЕРВЕР
resource "yandex_vpc_security_group" "zabbix_sg" {
  name       = "zabbix-sg"
  network_id = yandex_vpc_network.diplom_net.id

  # Веб-интерфейс Zabbix
  ingress {
    description    = "Zabbix web interface"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Zabbix Server порт для агентов (10051)
  ingress {
    description    = "Zabbix trapper port"
    protocol       = "TCP"
    port           = 10051
    v4_cidr_blocks = ["10.0.0.0/8"]
  }

  # SSH от бастиона
  ingress {
    description       = "SSH from bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion_sg.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#ГРУППА ДЛЯ ZABBIX АГЕНТОВ 
resource "yandex_vpc_security_group" "zabbix_agent_sg" {
  name       = "zabbix-agent-sg"
  network_id = yandex_vpc_network.diplom_net.id

  # Порт агента Zabbix (10050)
  ingress {
    description       = "Zabbix agent port from server"
    protocol          = "TCP"
    port              = 10050
    security_group_id = yandex_vpc_security_group.zabbix_sg.id
  }
}

# ========== ВЕБ-СЕРВЕРЫ ==========
resource "yandex_vpc_security_group" "web_sg" {
  name       = "web-sg"
  network_id = yandex_vpc_network.diplom_net.id

  # HTTP от балансировщика
  ingress {
    description       = "HTTP from ALB"
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb_sg.id
  }

  # SSH от бастиона
  ingress {
    description       = "SSH from bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion_sg.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#ELASTICSEARCH
resource "yandex_vpc_security_group" "elastic_sg" {
  name       = "elastic-sg"
  network_id = yandex_vpc_network.diplom_net.id

  ingress {
    description       = "Elasticsearch API from Kibana"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.kibana_sg.id
  }

  ingress {
    description       = "Elasticsearch from web servers"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.web_sg.id
  }

  ingress {
    description       = "SSH from bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion_sg.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#KIBANA 
resource "yandex_vpc_security_group" "kibana_sg" {
  name       = "kibana-sg"
  network_id = yandex_vpc_network.diplom_net.id

  ingress {
    description    = "Kibana web interface"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "SSH from bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion_sg.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}