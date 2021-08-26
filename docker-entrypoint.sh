#!/bin/bash
# ----------------------------------------------------------------
# Filename:       docker-entrypoint.sh
# Revision:       1.1
# Date:           2021-08-26
# Author:         pyker.zhang
# Email:          pyker@qq.com
# website:        www.ipyker.com
# Description:    使用shell写http web接口
# ----------------------------------------------------------------

# nginx支持fcgiwrap配置
cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen       80;
    server_name  localhost;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    location ~ ^/v1/api/(.*)$ {
        gzip off;
        default_type  text/plain;
        root   /data/shell;
        fastcgi_pass unix:/var/run/fcgiwrap.socket;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

# 创建shell脚本目录
mkdir -p /data/shell/v1/api

# 创建一个demo脚本
cat > /data/shell/v1/api/demo <<EOF
#!/bin/sh
echo "Content-Type:text/html;charset=utf-8"
echo ""

# 自动刷新
#echo '<script>window.setInterval(function(){
#    window.location.reload();
#},1000);</script>'
#echo '<meta http-equiv="refresh" content="60">'

# html页面css样式
#echo '<style>
#body{color:#cecece;}
#.title{color: #FF9800;border-left: 4px solid;padding: 4px;}
#pre{font-size:14px;border-left: 4px solid #4CAF50;padding: 5px;}
#</style>'

for i in a b c; do
	echo \$i
done

# Passing parameters
echo "\$QUERY_STRING" | awk -F '&' '{print \$1}'
echo "\$QUERY_STRING" | awk -F '&' '{print \$2}'

EOF

chmod +x /data/shell/v1/api/demo
/etc/init.d/fcgiwrap start
chmod 766 /var/run/fcgiwrap.socket
nginx -g "daemon off;"
