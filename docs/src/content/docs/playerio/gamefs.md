---
title: GameFS
slug: playerio/gamefs
description: GameFS
---

:::note
Part of PlayerIO backend services. Source: https://playerio.com/documentation/services/gamefs/.
:::

`GameFS` is used to store and distribute game files to players. TLSDZ access `GameFS` through the [`PlayerIO`](/playerio/playerio) client library.

```actionscript-3
// thelaststand.preloader.core/Main.as
// @line 114
PlayerIO.gameFS("dev-the-last-stand-iret8ormbeshajyk6woewg").getUrl(this._rootPath + "preloader.swf",this._useSSL)
```

This call instantiates the `GameFS` class with `gameId` of “dev-the-last-stand-iret8ormbeshajyk6woewg”. Once it is constructed, the `getUrl` method allows the game client to request a specific file path and get back a full URL that can be downloaded.

The `getUrl` method takes two arguments: a path string like `/game/data/preloader.swf`, and an optional `secure` boolean. If `secure` is true, the returned URL uses HTTPS; otherwise, it uses HTTP.

Internally, a URLMap processing happens. It is not known what it try to achieve. The full URL processing is simply:

```actionscript-3
// playerio/GameFS.as
// @line 31
return (param3 ? "https" : "http") + "://127.0.0.1:8080/r/" + param1 + param2;
```

- `param3` should be the secure flag.
- The string is TLSDZ domain name. In this case, we should replace it to our domain (e.g., 127.0.0.1).
- `param1` is the `gameId`. See [`gameId`](/dictionary#gameid)
- `param2` is a game file path. The `GameFS` enforce file path to start with a slash (/).

It will produce a URL like `http://127.0.0.1:8080/r/dev-the-last-stand-iret8ormbeshajyk6woewg/preloader.swf`.
