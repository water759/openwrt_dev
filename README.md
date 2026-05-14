# OpenWrt 迷你路由器管理网站

这是一个可运行在 OpenWrt（uhttpd + CGI）上的迷你管理站点，支持：

- 查看 WAN/LAN 实时收发流量（按接口）
- 查看防火墙当前状态（默认策略、转发开关、规则概览）
- 修改防火墙默认策略与转发开关，并应用配置

## 目录结构

- `www/index.html`：前端页面（纯 HTML/CSS/JS）
- `www/cgi-bin/traffic.sh`：流量查询 API（JSON）
- `www/cgi-bin/firewall.sh`：防火墙查询/修改 API（JSON）
- `scripts/install.sh`：安装脚本（复制文件、赋执行权限、重载 uhttpd）

## 依赖

- OpenWrt（带 `uhttpd`）
- `uci`、`ubus`、`jsonfilter`（常见默认组件）

## 安装

```sh
chmod +x scripts/install.sh
./scripts/install.sh
```

安装完成后访问：

- `http://<路由器IP>/mini-router/`

## API 说明

### GET `/cgi-bin/traffic.sh`

返回：

```json
{
  "ok": true,
  "interfaces": [
    {"name": "wan", "rx_bytes": 123, "tx_bytes": 456}
  ]
}
```

### GET `/cgi-bin/firewall.sh`

返回当前 firewall 默认配置和规则概要。

### POST `/cgi-bin/firewall.sh`

请求体（JSON）：

```json
{
  "input": "ACCEPT|REJECT|DROP",
  "output": "ACCEPT|REJECT|DROP",
  "forward": "ACCEPT|REJECT|DROP",
  "synflood_protect": "0|1"
}
```

服务端会执行：

- `uci set firewall.@defaults[0].*`
- `uci commit firewall`
- `/etc/init.d/firewall reload`

## 安全提示

- 该示例默认依赖局域网访问控制，不包含鉴权。
- 建议仅在内网使用，或结合 uhttpd ACL/认证。
- 生产使用前请增加 CSRF 防护、身份认证与操作审计。
