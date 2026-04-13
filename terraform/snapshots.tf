resource "yandex_compute_snapshot_schedule" "daily_backup_all" {
  name        = "daily-backup-all-servers"
  description = "Daily snapshots of all servers"

  schedule_policy {
    expression = "0 3 * * *"  
  }

  retention_period = "168h"  

  snapshot_spec {
    description = "Daily automated backup"
  }

  # Все сервера из inventory
  disk_ids = [
    yandex_compute_instance.bastion.boot_disk[0].disk_id,
    yandex_compute_instance.web1.boot_disk[0].disk_id,
    yandex_compute_instance.web2.boot_disk[0].disk_id,
    yandex_compute_instance.elastic.boot_disk[0].disk_id,
    yandex_compute_instance.zabbix.boot_disk[0].disk_id,
    yandex_compute_instance.kibana.boot_disk[0].disk_id,
  ]
}