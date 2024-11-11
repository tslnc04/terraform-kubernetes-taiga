resource "kubernetes_config_map_v1" "taiga_gateway_config" {
  metadata {
    name      = local.gateway_config_map
    namespace = var.namespace
  }

  data = {
    "default.conf" = <<-EOT
      server {
        listen 0.0.0.0:80;

        client_max_body_size 100M;
        charset utf-8;

        # Frontend
        location / {
            proxy_pass http://${var.front_domain}/;
            proxy_pass_header Server;
            proxy_set_header Host $http_host;
            proxy_redirect off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Scheme $scheme;
        }

        # API
        location /api/ {
            proxy_pass http://${var.back_domain}/api/;
            proxy_pass_header Server;
            proxy_set_header Host $http_host;
            proxy_redirect off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Scheme $scheme;
        }

        # Admin
        location /admin/ {
            proxy_pass http://${var.back_domain}/admin/;
            proxy_pass_header Server;
            proxy_set_header Host $http_host;
            proxy_redirect off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Scheme $scheme;
        }

        # Static
        location /static/ {
            alias /taiga/static/;
        }

        # Media
        location /_protected/ {
            internal;
            alias /taiga/media/;
            add_header Content-disposition "attachment";
        }

        # Unprotected section
        location /media/exports/ {
            alias /taiga/media/exports/;
            add_header Content-disposition "attachment";
        }

        location /media/ {
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Scheme $scheme;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://${var.protected_domain}/;
            proxy_redirect off;
        }

        # Events
        location /events {
            proxy_pass http://${var.events_domain}/events;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_connect_timeout 7d;
            proxy_send_timeout 7d;
            proxy_read_timeout 7d;
        }
      }
    EOT
  }
}
