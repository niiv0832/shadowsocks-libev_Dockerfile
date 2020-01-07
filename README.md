# Docker container for fast proxy setup based on Shadowsocks-libev proxy
Shadowsocks-libev Server running from config file (UDP mode)

docker run -d -v $YOUR_PATH_TO_JSON_CONFIG_DIR$:/etc/ss/cfg -p $YOUR_PORT$:80 -t niiv0832/sslibev_serv

In config must be port 80. Config file name must be "shadowsocks.json"
