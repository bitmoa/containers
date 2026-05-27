location ^~ {{location}} {
    alias "{{document_root}}";

    {{acl_configuration}}

    include "/opt/bitmoa/nginx/conf/bitmoa/00_protect-hidden-files.conf";
    include "/opt/bitmoa/nginx/conf/bitmoa/00_protect-uploads-dirs.conf";
    include "/opt/bitmoa/nginx/conf/bitmoa/php-fpm.conf";
}

{{additional_configuration}}
