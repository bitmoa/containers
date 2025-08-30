{{external_configuration}}

server {
    # Port to listen on, can also be set in IP:PORT format
    {{https_listen_configuration}}

    root {{document_root}};

    {{server_name_configuration}}

    ssl_certificate      bitmoa/certs/tls.crt;
    ssl_certificate_key  bitmoa/certs/tls.key;

    {{acl_configuration}}

    {{additional_configuration}}

    include  "/opt/bitmoa/nginx/conf/bitmoa/*.conf";
}
