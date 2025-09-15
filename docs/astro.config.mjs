// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import starlightThemeObsidian from "starlight-theme-obsidian";
import vercel from "@astrojs/vercel";
import rehypeExternalLinks from "rehype-external-links";

// https://astro.build/config
export default defineConfig({
  adapter: vercel({ imageService: true }),
  base: process.env.NODE_ENV === "production" ? "/" : "/",
  markdown: {
    rehypePlugins: [
      [
        rehypeExternalLinks,
        {
          content: { type: "text", value: " ↗" },
          target: "_blank",
          rel: ["noopener", "noreferrer"],
        },
      ],
    ],
  },
  integrations: [
    starlight({
      plugins: [starlightThemeObsidian()],
      favicon: "icon.ico",
      customCss: ["./src/assets/custom.css"],
      tableOfContents: { minHeadingLevel: 2, maxHeadingLevel: 6 },
      credits: true,
      lastUpdated: true,
      title: "TLSDZ",
      editLink: {
        baseUrl:
          "https://github.com/glennhenry/DeadZone-Documentation/edit/main/",
      },
      social: [
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/SulivanM/DeadZone-Private-Server",
        },
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/glennhenry/Recapturing-The-DeadZone",
        },
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/glennhenry/DeadZone-Documentation",
        },
        {
          icon: "discord",
          label: "Discord",
          href: "https://discord.gg/Q5dTKrPmfq",
        },
      ],
      sidebar: [
        { label: "Intro", slug: "index" },
        { label: "Glossary", slug: "glossary" },
        { label: "Architecture", slug: "architecture" },
        { label: "API Server", slug: "api-server" },
        { label: "preloader/Main.as", slug: "preloader-main" },
        { label: "core/Main.as", slug: "core-main" },
        { label: "core/Game.as", slug: "game" },
        { label: "core/Tutorial.as", slug: "tutorial" },
        {
          label: "playerio",
          collapsed: true,
          items: [
            {
              label: "utils",
              collapsed: true,
              items: [
                {
                  label: "BinarySerializer",
                  slug: "playerio/utils/binaryserializer",
                },
                { label: "Converter", slug: "playerio/utils/converter" },
                { label: "HTTPChannel", slug: "playerio/utils/httpchannel" },
              ],
            },
            {
              label: "generated.messages",
              collapsed: true,
              items: [
                { label: "Overview", slug: "playerio/generated/messages" },
              ],
            },
            { label: "BigDB", slug: "playerio/bigdb" },
            { label: "Connection", slug: "playerio/connection" },
            { label: "DatabaseObject", slug: "playerio/databaseobject" },
            { label: "GameFS", slug: "playerio/gamefs" },
            { label: "Message", slug: "playerio/message" },
            { label: "Multiplayer", slug: "playerio/multiplayer" },
            { label: "PlayerIO", slug: "playerio/playerio" },
            { label: "PlayerIOError", slug: "playerio/playerioerror" },
            {
              label: "PublishingNetwork",
              slug: "playerio/publishingnetwork",
            },
          ],
        },
        {
          label: "thelaststand.app",
          collapsed: true,
          items: [
            {
              label: "data",
              collapsed: true,
              items: [
                {
                  label: "AllianceDialogState",
                  slug: "thelaststand/app/data/alliancedialogstate",
                },
                {
                  label: "CostEntry",
                  slug: "thelaststand/app/data/costentry",
                },
                {
                  label: "CostTable",
                  slug: "thelaststand/app/data/costtable",
                },
                {
                  label: "Currency",
                  slug: "thelaststand/app/data/currency",
                },
                {
                  label: "FlagSet",
                  slug: "thelaststand/app/data/flagset",
                },
                {
                  label: "KeyFlags",
                  slug: "thelaststand/app/data/keyflags",
                },
                {
                  label: "NavigationLocation",
                  slug: "thelaststand/app/data/navigationlocation",
                },
                {
                  label: "NewsArticle",
                  slug: "thelaststand/app/data/newsarticle",
                },
                {
                  label: "Notification",
                  slug: "thelaststand/app/data/notification",
                },
                {
                  label: "PlayerData",
                  slug: "thelaststand/app/data/playerdata",
                },
                {
                  label: "PlayerFlags",
                  slug: "thelaststand/app/data/playerflags",
                },
                {
                  label: "PlayerUpgrades",
                  slug: "thelaststand/app/data/playerupgrades",
                },
                {
                  label: "RequirementTypes",
                  slug: "thelaststand/app/data/requirementtypes",
                },
              ],
            },
            {
              label: "game",
              collapsed: true,
              items: [
                {
                  label: "data",
                  collapsed: true,
                  items: [
                    {
                      label: "alliance",
                      collapsed: true,
                      items: [
                        {
                          label: "AllianceBannerData",
                          slug: "thelaststand/app/game/data/alliance/alliancebannerdata",
                        },
                        {
                          label: "AllianceData",
                          slug: "thelaststand/app/game/data/alliance/alliancedata",
                        },
                        {
                          label: "AllianceDataSummary",
                          slug: "thelaststand/app/game/data/alliance/alliancedatasummary",
                        },
                        {
                          label: "AllianceLifetimeStats",
                          slug: "thelaststand/app/game/data/alliance/alliancelifetimestats",
                        },
                        {
                          label: "AllianceList",
                          slug: "thelaststand/app/game/data/alliance/alliancelist",
                        },
                        {
                          label: "AllianceMember",
                          slug: "thelaststand/app/game/data/alliance/alliancemember",
                        },
                        {
                          label: "AllianceMemberList",
                          slug: "thelaststand/app/game/data/alliance/alliancememberlist",
                        },
                        {
                          label: "AllianceMessage",
                          slug: "thelaststand/app/game/data/alliance/alliancemessage",
                        },
                        {
                          label: "AllianceMessageList",
                          slug: "thelaststand/app/game/data/alliance/alliancemessagelist",
                        },
                        {
                          label: "AllianceRank",
                          slug: "thelaststand/app/game/data/alliance/alliancerank",
                        },
                        {
                          label: "AllianceRankPrivilege",
                          slug: "thelaststand/app/game/data/alliance/alliancerankprivilege",
                        },
                        {
                          label: "AllianceRound",
                          slug: "thelaststand/app/game/data/alliance/allianceround",
                        },
                        {
                          label: "AllianceTask",
                          slug: "thelaststand/app/game/data/alliance/alliancetask",
                        },
                        {
                          label: "TargetRecord",
                          slug: "thelaststand/app/game/data/alliance/targetrecord",
                        },
                      ],
                    },
                    {
                      label: "arena",
                      collapsed: true,
                      items: [
                        {
                          label: "ArenaSession",
                          slug: "thelaststand/app/game/data/arena/arenasession",
                        },
                        {
                          label: "ArenaStageData",
                          slug: "thelaststand/app/game/data/arena/arenastagedata",
                        },
                        {
                          label: "ArenaSystem",
                          slug: "thelaststand/app/game/data/arena/arenasystem",
                        },
                      ],
                    },
                    {
                      label: "assignment",
                      collapsed: true,
                      items: [
                        {
                          label: "AssignmentCollection",
                          slug: "thelaststand/app/game/data/assignment/assignmentcollection",
                        },
                        {
                          label: "AssignmentData",
                          slug: "thelaststand/app/game/data/assignment/assignmentdata",
                        },
                        {
                          label: "AssignmentStageData",
                          slug: "thelaststand/app/game/data/assignment/assignmentstagedata",
                        },
                        {
                          label: "AssignmentStageState",
                          slug: "thelaststand/app/game/data/assignment/assignmentstagestate",
                        },
                        {
                          label: "AssignmentType",
                          slug: "thelaststand/app/game/data/assignment/assignmenttype",
                        },
                      ],
                    },
                    {
                      label: "bounty",
                      collapsed: true,
                      items: [
                        {
                          label: "InfectedBounty",
                          slug: "thelaststand/app/game/data/bounty/infectedbounty",
                        },
                        {
                          label: "InfectedBountyTask",
                          slug: "thelaststand/app/game/data/bounty/infectedbountytask",
                        },
                        {
                          label: "InfectedBountyTaskCondition",
                          slug: "thelaststand/app/game/data/bounty/infectedbountytaskcondition",
                        },
                      ],
                    },
                    {
                      label: "effects",
                      collapsed: true,
                      items: [
                        {
                          label: "Cooldown",
                          slug: "thelaststand/app/game/data/effects/cooldown",
                        },
                        {
                          label: "CooldownType",
                          slug: "thelaststand/app/game/data/effects/cooldowntype",
                        },
                        {
                          label: "Effect",
                          slug: "thelaststand/app/game/data/effects/effect",
                        },
                        {
                          label: "EffectData",
                          slug: "thelaststand/app/game/data/effects/effectdata",
                        },
                        {
                          label: "EffectSaveFlags",
                          slug: "thelaststand/app/game/data/effects/effectsaveflags",
                        },
                        {
                          label: "EffectType",
                          slug: "thelaststand/app/game/data/effects/effecttype",
                        },
                      ],
                    },
                    {
                      label: "enemies",
                      collapsed: true,
                      items: [
                        {
                          label: "EnemyEliteType",
                          slug: "thelaststand/app/game/data/enemies/enemyelitetype",
                        },
                      ],
                    },
                    {
                      label: "injury",
                      collapsed: true,
                      items: [
                        {
                          label: "Injury",
                          slug: "thelaststand/app/game/data/injury/injury",
                        },
                        {
                          label: "InjuryCause",
                          slug: "thelaststand/app/game/data/injury/injurycause",
                        },
                        {
                          label: "InjuryList",
                          slug: "thelaststand/app/game/data/injury/injurylist",
                        },
                        {
                          label: "InjurySeverity",
                          slug: "thelaststand/app/game/data/injury/injuryseverity",
                        },
                      ],
                    },
                    {
                      label: "quests",
                      collapsed: true,
                      items: [
                        {
                          label: "DynamicQuest",
                          slug: "thelaststand/app/game/data/quests/dynamicquest",
                        },
                        {
                          label: "GlobalQuestData",
                          slug: "thelaststand/app/game/data/quests/globalquestdata",
                        },
                        {
                          label: "Quest",
                          slug: "thelaststand/app/game/data/quests/quest",
                        },
                      ],
                    },
                    {
                      label: "raid",
                      collapsed: true,
                      items: [
                        {
                          label: "RaidData",
                          slug: "thelaststand/app/game/data/raid/raiddata",
                        },
                        {
                          label: "RaidStageData",
                          slug: "thelaststand/app/game/data/raid/raidstagedata",
                        },
                        {
                          label: "RaidStageObjectiveState",
                          slug: "thelaststand/app/game/data/raid/raidstageobjectivestate",
                        },
                      ],
                    },
                    {
                      label: "research",
                      collapsed: true,
                      items: [
                        {
                          label: "ResearchEffect",
                          slug: "thelaststand/app/game/data/research/researcheffect",
                        },
                        {
                          label: "ResearchState",
                          slug: "thelaststand/app/game/data/research/researchstate",
                        },
                        {
                          label: "ResearchTask",
                          slug: "thelaststand/app/game/data/research/researchtask",
                        },
                      ],
                    },
                    {
                      label: "notification",
                      collapsed: true,
                      items: [
                        {
                          label: "NotificationType",
                          slug: "thelaststand/app/game/data/notification/notificationtype",
                        },
                      ],
                    },
                    {
                      label: "skills",
                      collapsed: true,
                      items: [
                        {
                          label: "SkillCollection",
                          slug: "thelaststand/app/game/data/skills/skillcollection",
                        },
                        {
                          label: "SkillState",
                          slug: "thelaststand/app/game/data/skills/skillstate",
                        },
                      ],
                    },
                    {
                      label: "store",
                      collapsed: true,
                      items: [
                        {
                          label: "StoreCollection",
                          slug: "thelaststand/app/game/data/store/storecollection",
                        },
                        {
                          label: "StoreItem",
                          slug: "thelaststand/app/game/data/store/storeitem",
                        },
                        {
                          label: "StoreSale",
                          slug: "thelaststand/app/game/data/store/storesale",
                        },
                      ],
                    },
                    {
                      label: "task",
                      collapsed: true,
                      items: [
                        {
                          label: "JunkRemovalTask",
                          slug: "thelaststand/app/game/data/task/junkremovaltask",
                        },
                      ],
                    },
                    {
                      label: "AmmoType",
                      slug: "thelaststand/app/game/data/ammotype",
                    },
                    {
                      label: "AttireData",
                      slug: "thelaststand/app/game/data/attiredata",
                    },
                    {
                      label: "AttireFlags",
                      slug: "thelaststand/app/game/data/attireflags",
                    },
                    {
                      label: "AttireOverlay",
                      slug: "thelaststand/app/game/data/attireoverlay",
                    },
                    {
                      label: "AttributeClass",
                      slug: "thelaststand/app/game/data/attributeclass",
                    },
                    {
                      label: "AttributeOptions",
                      slug: "thelaststand/app/game/data/attributeoptions",
                    },
                    {
                      label: "Attributes",
                      slug: "thelaststand/app/game/data/attributes",
                    },
                    {
                      label: "BatchRecycleJob",
                      slug: "thelaststand/app/game/data/batchrecyclejob",
                    },
                    {
                      label: "BatchRecycleJobCollection",
                      slug: "thelaststand/app/game/data/batchrecyclejobcollection",
                    },
                    {
                      label: "Building",
                      slug: "thelaststand/app/game/data/building",
                    },
                    {
                      label: "BuildingCollection",
                      slug: "thelaststand/app/game/data/buildingcollection",
                    },
                    {
                      label: "CompoundData",
                      slug: "thelaststand/app/game/data/compounddata",
                    },
                    {
                      label: "CooldownCollection",
                      slug: "thelaststand/app/game/data/cooldowncollection",
                    },
                    {
                      label: "CraftingInfo",
                      slug: "thelaststand/app/game/data/craftinginfo",
                    },
                    {
                      label: "CrateItem",
                      slug: "thelaststand/app/game/data/crateitem",
                    },
                    {
                      label: "DamageType",
                      slug: "thelaststand/app/game/data/damagetype",
                    },
                    {
                      label: "EffectCollection",
                      slug: "thelaststand/app/game/data/effectcollection",
                    },
                    {
                      label: "EffectItem",
                      slug: "thelaststand/app/game/data/effectitem",
                    },
                    {
                      label: "EnemyResults",
                      slug: "thelaststand/app/game/data/enemyresults",
                    },
                    {
                      label: "GameResources",
                      slug: "thelaststand/app/game/data/gameresources",
                    },
                    {
                      label: "Gear",
                      slug: "thelaststand/app/game/data/gear",
                    },
                    {
                      label: "GearClass",
                      slug: "thelaststand/app/game/data/gearclass",
                    },
                    {
                      label: "GearType",
                      slug: "thelaststand/app/game/data/geartype",
                    },
                    {
                      label: "Gender",
                      slug: "thelaststand/app/game/data/gender",
                    },
                    {
                      label: "HumanAppearance",
                      slug: "thelaststand/app/game/data/humanappearance",
                    },
                    {
                      label: "Inventory",
                      slug: "thelaststand/app/game/data/inventory",
                    },
                    {
                      label: "Item",
                      slug: "thelaststand/app/game/data/item",
                    },
                    {
                      label: "ItemAttributes",
                      slug: "thelaststand/app/game/data/itemattributes",
                    },
                    {
                      label: "ItemBindState",
                      slug: "thelaststand/app/game/data/itembindstate",
                    },
                    {
                      label: "ItemBonusStats",
                      slug: "thelaststand/app/game/data/itembonusstats",
                    },
                    {
                      label: "ItemCounterType",
                      slug: "thelaststand/app/game/data/itemcountertype",
                    },
                    {
                      label: "ItemQualityType",
                      slug: "thelaststand/app/game/data/itemqualitytype",
                    },
                    {
                      label: "JunkBuilding",
                      slug: "thelaststand/app/game/data/junkbuilding",
                    },
                    {
                      label: "MedicalItem",
                      slug: "thelaststand/app/game/data/medicalitem",
                    },
                    {
                      label: "MiscEffectItem",
                      slug: "thelaststand/app/game/data/misceffectitem",
                    },
                    {
                      label: "MissionCollection",
                      slug: "thelaststand/app/game/data/missioncollection",
                    },
                    {
                      label: "MissionData",
                      slug: "thelaststand/app/game/data/missiondata",
                    },
                    {
                      label: "MissionStats",
                      slug: "thelaststand/app/game/data/missionstats",
                    },
                    {
                      label: "Morale",
                      slug: "thelaststand/app/game/data/morale",
                    },
                    {
                      label: "SchematicItem",
                      slug: "thelaststand/app/game/data/schematicitem",
                    },

                    {
                      label: "Survivor",
                      slug: "thelaststand/app/game/data/survivor",
                    },
                    {
                      label: "SurvivorAppearance",
                      slug: "thelaststand/app/game/data/survivorappearance",
                    },
                    {
                      label: "SurvivorClass",
                      slug: "thelaststand/app/game/data/survivorclass",
                    },
                    {
                      label: "SurvivorClassWeapons",
                      slug: "thelaststand/app/game/data/survivorclassweapons",
                    },
                    {
                      label: "SurvivorCollection",
                      slug: "thelaststand/app/game/data/survivorcollection",
                    },
                    {
                      label: "SurvivorData",
                      slug: "thelaststand/app/game/data/survivordata",
                    },
                    {
                      label: "SurvivorLoadout",
                      slug: "thelaststand/app/game/data/survivorloadout",
                    },
                    {
                      label: "SurvivorLoadoutData",
                      slug: "thelaststand/app/game/data/survivorloadoutdata",
                    },
                    {
                      label: "SurvivorLoadoutEntry",
                      slug: "thelaststand/app/game/data/survivorloadoutentry",
                    },
                    {
                      label: "SurvivorState",
                      slug: "thelaststand/app/game/data/survivorstate",
                    },
                    {
                      label: "Task",
                      slug: "thelaststand/app/game/data/task",
                    },
                    {
                      label: "TaskCollection",
                      slug: "thelaststand/app/game/data/taskcollection",
                    },
                    {
                      label: "TaskStatus",
                      slug: "thelaststand/app/game/data/taskstatus",
                    },
                    {
                      label: "TaskType",
                      slug: "thelaststand/app/game/data/tasktype",
                    },
                    {
                      label: "TimerData",
                      slug: "thelaststand/app/game/data/timerdata",
                    },
                    {
                      label: "Weapon",
                      slug: "thelaststand/app/game/data/weapon",
                    },
                    {
                      label: "WeaponClass",
                      slug: "thelaststand/app/game/data/weaponclass",
                    },
                    {
                      label: "WeaponData",
                      slug: "thelaststand/app/game/data/weapondata",
                    },
                    {
                      label: "WeaponFlags",
                      slug: "thelaststand/app/game/data/weaponflags",
                    },
                    {
                      label: "WeaponType",
                      slug: "thelaststand/app/game/data/weapontype",
                    },
                  ],
                },
              ],
            },
            {
              label: "network",
              collapsed: true,
              items: [
                {
                  label: "Network",
                  slug: "thelaststand/app/network/network",
                },
                {
                  label: "NetworkMessage",
                  slug: "thelaststand/app/network/networkmessage",
                },
                {
                  label: "PlayerIOConnector",
                  slug: "thelaststand/app/network/playerioconnector",
                },
                {
                  label: "RemotePlayerData",
                  slug: "thelaststand/app/network/remoteplayerdata",
                },
              ],
            },
          ],
        },
      ],
    }),
  ],
});
