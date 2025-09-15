---
title: PublishingNetwork
slug: playerio/publishingnetwork
description: PublishingNetwork
---

:::note
Part of PlayerIO backend authentication services. Source: https://playerio.com/documentation/services/authentication/publishingnetwork, https://playerio.com/documentation/publishingnetwork/canvas.
:::

PlayerIO Publishing Network is a platform for developers to publish their games across a network of interconnected sites. This enables them to distribute their games to multiple partner websites with a single submission.

TLSDZ registered its game within this network, allowing it to be featured on the [playsian](https://playsian.com/laststand), one of the affiliated site within the network. Players accessing the game within a publishing network sites must complete [authentication via PlayerIO](/thelaststand/app/network/playerioconnector#authenticate-by-playerio).

Sites participating in the publishing network must provide publishing network canvas, which is an iframe that the game will be running on. The canvas has a `userToken` used for authentication purposes. When authenticating, developers of the game may need to validate this token. This process ensures that players are genuinely accessing the game from canvas in one of the registered network sites.

In the game code, `PublishingNetwork` is a class that handles the authentication for games that are published within the PlayerIO Publishing Network. There are also some related class:

- `PublishingNetworkDialog`: Handles dialog messages for login.
- `PublishingNetworkPayments`: Handles payment.
- `PublishingNetworkProfile`: Handles the user detailed profile.
- `PublishingNetworkProfiles`: Handles the loading and the display of a profile.
- `PublishingNetworkRelations`: Handles relation between players (i.e., friend system).
