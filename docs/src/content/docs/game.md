---
title: Game
slug: game
description: Game
---

The second 'main' of the game.

### gotoCompound

This method will be called when we enter the game. This loads the compound scene from `xml/scenes/compound.xml`.

:::note
The game doesn't request any scenes XML, so the server must send this beforehand. This was done in [game ready message](/thelaststand/app/network/network#ongameready).
:::
