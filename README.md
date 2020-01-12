# Docker container for fast proxy setup based on Shadowsocks-libev proxy
Shadowsocks-libev Server running from config file (UDP mode).

## Links:
Link on docker hub: <a href="https://hub.docker.com/r/niiv0832/sslibev_serv">niiv0832/sslibev_serv</a>

Link on github: <a href="https://www.github.com/niiv0832/shadowsocks-libev_Dockerfile">niiv0832/shadowsocks-libev_Dockerfile</a>

## Usage

```shell
docker run -d --name=ssserv --restart=always -v $YOUR_PATH_TO_JSON_CONFIG_DIR$:/etc/ss/cfg -p $YOUR_PORT$:80 -t niiv0832/sslibev_serv
```

In config must be port `80`. Config file name must be `"shadowsocks.json"`.
