---
title: PlayerIO
slug: playerio/playerio
description: PlayerIO
---

:::note
Part of PlayerIO backend services. Source: https://playerio.com/documentation/reference/actionscript3/playerio.playerio.
:::

The `PlayerIO` class serves as a networking bridge to [`GameFS`](/playerio/gamefs) and handles authentication.

The [`PlayerIOConnector`](/thelaststand/app/network/playerioconnector) is responsible for making authentication calls to this class. It selects the appropriate authentication method based on how the game authenticates (e.g., `connectViaFacebook`, `connectViaArmorGames`, `connectViaPlayerIO`).

Currently, our server uses PlayerIO for authentication. The `PlayerIOConnector` uses the `connectViaPlayerIO` method, which in turn calls the static method `PlayerIO.authenticate()` to carry out the authentication process. Within the `PlayerIO` class, this leads to calls to the generated `authenticate` method in the `playerio.generated.PlayerIO` package, ultimately resulting in a call to [API 13](/api-server#api-13).
