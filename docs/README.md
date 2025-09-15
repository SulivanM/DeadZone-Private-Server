# DeadZone Documentation

Repository for the [DeadZone Documentation](https://dead-zone-documentation.vercel.app/) website.

The private server repository: [DeadZone Private Server](https://github.com/SulivanM/DeadZone-Private-Server).

To run the website locally, clone the repo and then:

```
npm install
npm run dev
```

### How to add new page:

1. A page must be `.md` file and is enforced to have this on top of them (frontmatter):

```
---
title: Subfolder Example
slug: playerio/subfolder-example/subfolder
description: example
---
```

2. Replace the title appropriately. The description is optional, so you can set it to be the same as the title. Any images or videos should be placed in `src/assets/`.
3. The slug is produced from the directory structure based on the game packages. For example, `playerioconnector.md` exists within the `thelaststand.app.network` package, thus the final slug is `thelaststand/app/network/playerioconnector`.
4. Next, add the page to the sidebar.

   1. Begin by editing the `astro.config.mjs`.
   2. Follow the existing sidebar link format. You can create new groups or place it in existing ones based on the page topic.

   Sidebar lists are based on game packages. Long package names can be shortened (e.g., `thelaststand.app`). If a package has several child packages, we can make a group for them (e.g., `network` under `thelaststand.app`).
