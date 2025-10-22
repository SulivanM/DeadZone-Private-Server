# Broadcast System Guide

## Overview

Le système de broadcast permet au serveur d'envoyer des messages en temps réel à tous les clients Flash connectés. Ces messages apparaissent dans le `BroadcastDisplay` en bas de l'écran dans le jeu.

## Configuration

### application.yaml

```yaml
broadcast:
  enabled: true                    # Active/désactive le broadcast
  host: "0.0.0.0"                 # Adresse d'écoute
  ports: "2121,2122,2123"         # Ports pour différents services
  enablePolicyServer: true         # Active le policy file server (port 843)
```

## Utilisation dans le code

### Envoi de messages simples

```kotlin
// Message texte simple
BroadcastService.broadcastPlainText("Bienvenue sur le serveur!")

// Message admin
BroadcastService.broadcastAdmin("Maintenance dans 5 minutes")

// Message d'avertissement
BroadcastService.broadcastWarning("Attention: Zombie horde incoming!")
```

### Événements de jeu

```kotlin
// Item trouvé
BroadcastService.broadcastItemFound("PlayerName", "Legendary Sword", "Legendary")

// Item unboxed (crate ouvert)
BroadcastService.broadcastItemUnboxed("PlayerName", "Epic Armor", "Epic")

// Item crafté
BroadcastService.broadcastItemCrafted("PlayerName", "Master Weapon")

// Achievement débloqué
BroadcastService.broadcastAchievement("PlayerName", "First Blood")

// Niveau atteint
BroadcastService.broadcastUserLevel("PlayerName", 50)
```

### Événements PvP/Raid

```kotlin
// Attaque de raid
BroadcastService.broadcastRaidAttack("Attacker", "Defender", "Victory")

// Défense de raid
BroadcastService.broadcastRaidDefend("Defender", "Attacker", "Success")

// Bounty ajoutée
BroadcastService.broadcastBountyAdd("PlayerName", 5000)

// Bounty collectée
BroadcastService.broadcastBountyCollected("Hunter", "Target", 5000)
```

### Événements d'alliance

```kotlin
// Raid d'alliance réussi
BroadcastService.broadcastAllianceRaidSuccess("AllianceName", "TargetName")

// Classement d'alliance
BroadcastService.broadcastAllianceRank("AllianceName", 1)
```

### Missions

```kotlin
// Mission de raid commencée
BroadcastService.broadcastRaidMissionStarted("PlayerName", "MissionName")

// Mission complétée
BroadcastService.broadcastRaidMissionComplete("PlayerName", "MissionName")

// Mission échouée
BroadcastService.broadcastRaidMissionFailed("PlayerName", "MissionName")
```

### Hazards

```kotlin
// Hazard réussi
BroadcastService.broadcastHazSuccess("PlayerName", "HazardName")

// Hazard échoué
BroadcastService.broadcastHazFail("PlayerName", "HazardName")
```

### Messages personnalisés

```kotlin
// Créer un message personnalisé
val message = BroadcastMessage(
    protocol = BroadcastProtocol.PLAIN_TEXT,
    arguments = listOf("Mon message personnalisé")
)
BroadcastService.broadcast(message)

// Ou avec les arguments multiples
val message = BroadcastMessage(
    protocol = BroadcastProtocol.ITEM_FOUND,
    arguments = listOf("PlayerName", "ItemName", "Quality")
)
BroadcastService.broadcast(message)
```

## API REST (en mode développement)

### Obtenir le statut

```bash
GET http://localhost:8080/api/broadcast/status
```

Réponse:
```json
{
  "enabled": true,
  "clientCount": 2
}
```

### Envoyer un message de test

```bash
POST http://localhost:8080/api/broadcast/test
Content-Type: application/json

{
  "message": "Test message from API"
}
```

### Envoyer un message personnalisé

```bash
POST http://localhost:8080/api/broadcast/send
Content-Type: application/json

{
  "protocol": "plain",
  "arguments": ["Hello from API!"]
}
```

Exemple avec item:
```bash
POST http://localhost:8080/api/broadcast/send
Content-Type: application/json

{
  "protocol": "itmfd",
  "arguments": ["PlayerName", "Legendary Weapon", "Legendary"]
}
```

## Protocoles disponibles

| Code | Protocole | Description |
|------|-----------|-------------|
| `static` | STATIC | Message statique |
| `admin` | ADMIN | Message administrateur |
| `warn` | WARNING | Avertissement |
| `shtdn` | SHUT_DOWN | Arrêt du serveur |
| `itmbx` | ITEM_UNBOXED | Item déballé |
| `itmfd` | ITEM_FOUND | Item trouvé |
| `raid` | RAID_ATTACK | Attaque de raid |
| `def` | RAID_DEFEND | Défense de raid |
| `crft` | ITEM_CRAFTED | Item crafté |
| `ach` | ACHIEVEMENT | Achievement |
| `lvl` | USER_LEVEL | Niveau utilisateur |
| `srvcnt` | SURVIVOR_COUNT | Nombre de survivants |
| `zfail` | ZOMBIE_ATTACK_FAIL | Échec attaque zombie |
| `injall` | ALL_INJURED | Tous blessés |
| `plain` | PLAIN_TEXT | Texte simple |
| `badd` | BOUNTY_ADD | Bounty ajoutée |
| `bcol` | BOUNTY_COLLECTED | Bounty collectée |
| `ars` | ALLIANCE_RAID_SUCCESS | Raid alliance réussi |
| `arank` | ALLIANCE_RANK | Classement alliance |
| `arenalb` | ARENA_LEADERBOARD | Leaderboard arène |
| `rmstart` | RAIDMISSION_STARTED | Mission raid commencée |
| `rmcompl` | RAIDMISSION_COMPLETE | Mission raid complétée |
| `rmfail` | RAIDMISSION_FAILED | Mission raid échouée |
| `hazwin` | HAZ_SUCCESS | Hazard réussi |
| `hazlose` | HAZ_FAIL | Hazard échoué |

## Format de message

Les messages sont envoyés au format: `protocol:arg1|arg2|arg3\0`

Exemples:
- `plain:Hello World!\0`
- `itmfd:PlayerName|Legendary Sword|Legendary\0`
- `lvl:PlayerName|50\0`
- `\0` (heartbeat vide)

## Test automatique

En mode développement, le serveur envoie automatiquement des messages de test toutes les 3 secondes après le démarrage pour vérifier que le système fonctionne.

Pour activer/désactiver:
```yaml
ktor:
  development: true  # true = active les tests automatiques
```

## Intégration dans votre code

### Exemple: Envoyer un broadcast quand un joueur trouve un item rare

```kotlin
// Dans votre ItemService ou InventoryService
fun onItemFound(playerName: String, item: Item) {
    if (item.quality == ItemQuality.LEGENDARY) {
        BroadcastService.broadcastItemFound(
            playerName = playerName,
            itemName = item.name,
            quality = "Legendary"
        )
    }
}
```

### Exemple: Broadcast lors d'un raid réussi

```kotlin
// Dans votre RaidService
fun onRaidCompleted(attacker: Player, defender: Player, success: Boolean) {
    if (success) {
        BroadcastService.broadcastRaidAttack(
            attackerName = attacker.name,
            defenderName = defender.name,
            result = "Victory"
        )
    }
}
```

### Exemple: Broadcast lors d'un level up

```kotlin
// Dans votre PlayerService
fun onLevelUp(player: Player, newLevel: Int) {
    if (newLevel % 10 == 0) { // Broadcast tous les 10 niveaux
        BroadcastService.broadcastUserLevel(player.name, newLevel)
    }
}
```

## Troubleshooting

### Le client ne se connecte pas

1. Vérifiez que le serveur écoute sur le bon port (2121 par défaut)
2. Vérifiez que le policy server tourne sur le port 843 (nécessite admin/root)
3. Sur Windows, lancez le serveur en tant qu'administrateur
4. Vérifiez les logs: `[+] BroadcastSystem: Connected`

### Les messages n'apparaissent pas

1. Vérifiez que le broadcast est activé: `BroadcastService.isEnabled()`
2. Vérifiez le nombre de clients connectés: `BroadcastService.getClientCount()`
3. Testez avec l'API REST: `POST /api/broadcast/test`
4. Vérifiez les logs serveur pour voir si les messages sont envoyés

### Port 843 non accessible

Si vous ne pouvez pas utiliser le port 843 (nécessite privilèges):
1. Désactivez le policy server: `enablePolicyServer: false`
2. Créez un fichier `crossdomain.xml` à la racine de votre serveur web
3. Ou utilisez un proxy/redirect vers un port plus élevé
