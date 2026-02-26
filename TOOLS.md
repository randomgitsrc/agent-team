# TOOLS.md - Local Notes (Private)

> ⚠️ 私密文件 — 仅 CEO（阿九）可见  
> 存放环境相关敏感信息（如 SSH、API key 位置），不对专家子会话开放。

## What Goes Here

- 摄像头名称与位置
- SSH 主机与别名
- API key 存放路径（不记录 key 本身）
- TTS 偏好音色
- 房间 / 设备命名
- 其他本地环境相关信息

## Browser
You have access to a real web browser tool. Use the browser when:
- information may be outdated
- user asks to search or check websites
- verification is needed
- interaction with webpages is required

Browser capabilities:
- open URLs
- search the web
- read page content
- click elements
- extract information

Always prefer using the browser instead of guessing.

Profile: `openclaw` (CDP on port 18800, Chrome at `/usr/bin/google-chrome`)
Start script: `~/.start-openclaw-chrome.sh`

### 操作注意事项
- 打开新页面后**必须等待加载完成**再截图，否则只会截到空白/加载中状态
  - 方法：`act` with `{"kind": "wait", "timeMs": 3000}` 后再 screenshot
- 截图默认是当前视口（非全页），与用户看到的一致；fullPage=true 才是完整长页
- gateway 断线后浏览器工具会超时报错，需用户执行 `openclaw gateway restart` 恢复
- 截图后用 `message(action=send, media=<path>)` 发给用户，不要直接回复路径
- 表单输入用 `act` + `{"kind": "type", "ref": "...", "submit": true}`，ref 从 snapshot 获取

## Examples

### Cameras
- living-room → 主活动区，180° 广角
- front-door → 入户门口，移动触发

### SSH
- home-server → 192.168.1.100，user: admin

### API Keys（路径）
- OpenAI / Gemini / Kimi: `~/.openclaw/.env`

### TTS
- Preferred voice: "Nova"
- Default speaker: Kitchen HomePod

---

这是你的环境小抄，需要什么就往里记。
