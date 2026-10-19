
job "devops-intern-final" {
  datacenters = ["dc1"]
  type        = "service"

  group "nginx" {
    count          = 1
    shutdown_delay = "5s"

    network {
      port "http" {
        to = 8080
      }
    }

    update {
      max_parallel      = 1
      min_healthy_time  = "10s"
      healthy_deadline  = "2m"
      progress_deadline = "5m"
      auto_revert       = true
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    reschedule {
      attempts       = 3
      interval       = "1h"
      delay          = "15s"
      delay_function = "exponential"
      max_delay      = "5m"
      unlimited      = false
    }

    service {
      name     = "devops-intern-final"
      provider = "consul"
      port     = "http"

      check {
        name     = "nginx-health"
        type     = "http"
        path     = "/healthz"
        interval = "10s"
        timeout  = "2s"
        port     = "http"
      }
    }

    task "nginx" {
      driver = "docker"

      config {
        image      = "devops-intern-final:local"
        ports      = ["http"]
        force_pull = false
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}

