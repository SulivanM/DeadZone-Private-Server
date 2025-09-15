package dev.deadzone.socket.handler.save.mission.response

import dev.deadzone.socket.handler.save.BaseResponse
import kotlinx.serialization.Serializable
import java.io.File
import java.io.InputStreamReader
import java.util.zip.GZIPInputStream

// SaveDataMethod.MISSION_START, MissionData.as line 685
@Serializable
data class MissionStartResponse(
    val disabled: Boolean = false,
    val id: String,
    val time: Int,
    val assignmentType: String,
    val areaClass: String,
    val automated: Boolean = false,
    val sceneXML: String,
    val z: List<String>,
    val allianceAttackerEnlisting: Boolean,
    val allianceAttackerLockout: Boolean,
    val allianceAttackerAllianceId: String?,
    val allianceAttackerAllianceTag: String?,
    val allianceMatch: Boolean,
    val allianceRound: Int,
    val allianceRoundActive: Boolean,
    val allianceError: Boolean,
    val allianceAttackerWinPoints: Int,
) : BaseResponse()

fun resolveAndLoadScene(areaType: String): String? {
    val scene = areaTypeToScenes[areaType]?.random()
    return scene?.let { loadSceneXML(it) }
}

fun loadSceneXML(filename: String): String {
    val path = "static/game/data/xml/scenes/$filename.xml.gz"
    val file = File(path)

    GZIPInputStream(file.inputStream()).use { gzipStream ->
        InputStreamReader(gzipStream, Charsets.UTF_8).use { reader ->
            return reader.readText()
        }
    }
}

val areaTypeToScenes = mapOf(
    // missing:
    // Convenience Store (areaType: tutorialStore)
    // Department Store (areaType: deptStore)
    // Forest (areaType: forest)
    // Suburban Street (areaType: substreet)
    // Street (areaType: street)

    "compound" to listOf(
        "compound"
    ),
    "bridge" to listOf(
        "exterior-bridge-1",
        "exterior-bridge-2",
        "exterior-bridge-3"
    ),
    "cityBlock" to listOf(
        "exterior-cityblock-1",
        "exterior-cityblock-2",
        "exterior-cityblock-3",
        "exterior-cityblock-4",
        "exterior-cityblock-5"
    ),
    "constSiteLarge" to listOf(
        "exterior-construction-1",
        "exterior-construction-2",
        "exterior-construction-3"
    ),
    "constSiteSmall" to listOf(
        "exterior-construction-small-1",
        "exterior-construction-small-2",
        "exterior-construction-small-3"
    ),
    "depot" to listOf(
        "exterior-depot-1",
        "exterior-depot-2",
        "exterior-depot-3"
    ),
    "dock" to listOf(
        "exterior-dock-1",
        "exterior-dock-2"
    ),
    "farm" to listOf(
        "exterior-farm-1",
        "exterior-farm-2",
    ),
    "highway" to listOf(
        "exterior-highway-1",
        "exterior-highway-2",
        "exterior-highway-3",
    ),
    "highwaySmall" to listOf(
        "exterior-highway-small-1",
        "exterior-highway-small-2",
        "exterior-highway-small-3",
    ),
    "militarybase" to listOf(
        "exterior-militarybase-1",
        "exterior-militarybase-2",
        "exterior-militarybase-3"
    ),
    "militaryDock" to listOf(
        "exterior-militarydock-1",
        "exterior-militarydock-2",
    ),
    "motelLarge" to listOf(
        "exterior-motel-1",
        "exterior-motel-2",
        "exterior-motel-3"
    ),
    "motel" to listOf(
        "exterior-motel-small-1",
        "exterior-motel-small-2",
        "exterior-motel-small-3"
    ),
    "parkLarge" to listOf(
        "exterior-park-large-1",
        "exterior-park-large-2",
        "exterior-park-large-3"
    ),
    "parkMedium" to listOf(
        "exterior-park-medium-1",
        "exterior-park-medium-2",
        "exterior-park-medium-3"
    ),
    "prison" to listOf(
        "exterior-prison-1",
        "exterior-prison-2",
        "exterior-prison-3",
    ),
    "shoppingstrip" to listOf(
        "exterior-shoppingstrip-1",
        "exterior-shoppingstrip-2",
    ),
    "shoppingStripSmall" to listOf(
        "exterior-shoppingstrip-small-1",
        "exterior-shoppingstrip-small-2",
    ),
    "subblock" to listOf(
        "exterior-subblock-1",
        "exterior-subblock-2"
    ),
    "trainStationLarge" to listOf(
        "exterior-trainstation-1",
        "exterior-trainstation-2"
    ),
    "trainStationSmall" to listOf(
        "exterior-trainstation-small-1",
        "exterior-trainstation-small-2"
    ),
    "trainYard" to listOf(
        "exterior-trainyard-1",
        "exterior-trainyard-2"
    ),
    "gunStore" to listOf(
        "interior-gunstore-1",
        "interior-gunstore-2",
        "interior-gunstore-3"
    ),
    "hardwareStoreLarge" to listOf(
        "interior-hardwarestore-large-1",
        "interior-hardwarestore-large-2",
        "interior-hardwarestore-large-3"
    ),
    "hospital" to listOf(
        "interior-hospital-1",
        "interior-hospital-2",
        "interior-hospital-3"
    ),
    "officeLarge" to listOf(
        "interior-office-large-1",
        "interior-office-large-2",
        "interior-office-large-3"
    ),
    "officeMedium" to listOf(
        "interior-office-medium-1",
        "interior-office-medium-2"
    ),
    "office" to listOf(
        "interior-office-small-1"
    ),
    "police" to listOf(
        "interior-police-large-1",
        "interior-police-large-2",
        "interior-police-large-3",
        "interior-police-medium-1",
        "interior-police-medium-2",
        "interior-police-medium-3"
    ),
    "residential" to listOf(
        "interior-residential",
        "interior-residential-2",
        "interior-residential-3",
        "interior-residential-4",
        "interior-residential-5"
    ),
    "resLarge" to listOf(
        "interior-residential-large-1",
        "interior-residential-large-2",
        "interior-residential-large-3"
    ),
    "security" to listOf(
        "interior-security-1",
        "interior-security-2",
        "interior-security-3",
    ),
    "store" to listOf(
        "interior-store-1",
        "interior-store-2",
        "interior-store-3"
    ),
    // No idea if this is the right one lol
    "tutorialStore" to listOf(
        "interior-store-small-1",
        "interior-store-small-2"
    ),
    "hardwareStore" to listOf(
        "interior-store-small-1",
        "interior-store-small-2"
    ),
    "subway" to listOf(
        "interior-subway-1",
        "interior-subway-2",
        "interior-subway-3"
    ),
    "subwayLarge" to listOf(
        "interior-subway-large-1",
        "interior-subway-large-2",
        "interior-subway-large-3"
    ),
    "superMarket" to listOf(
        "interior-supermarket-1",
        "interior-supermarket-2"
    ),
    "superMarketLarge" to listOf(
        "interior-supermarket-large-1",
        "interior-supermarket-large-2"
    ),
    "warehouse" to listOf(
        "interior-warehouse-1",
        "interior-warehouse-2",
        "interior-warehouse-3"
    ),
    "warehouseMedium" to listOf(
        "interior-warehouse-small-1",
        "interior-warehouse-small-2",
        "interior-warehouse-small-3"
    ),
    "streetSmall" to listOf(
        "street-small-1",
        "street-small-2",
        "street-small-3"
    ),

    // Others
    // Raid
    "raidBridgeHuman" to listOf(
        "raid-island-bridge-human-01",
        "raid-island-bridge-human-02",
        "raid-island-bridge-human-03"
    ),
    "raidBridgeZombie" to listOf(
        "raid-island-bridge-zombie-01",
        "raid-island-bridge-zombie-02",
        "raid-island-bridge-zombie-03"
    ),
    "raidCompoundHuman" to listOf(
        "raid-island-compound-human-01",
        "raid-island-compound-human-02",
        "raid-island-compound-human-03"
    ),
    "raidCompoundZombie" to listOf(
        "raid-island-compound-zombie-01",
        "raid-island-compound-zombie-02",
        "raid-island-compound-zombie-03"
    ),
    "raidMonumentHuman" to listOf(
        "raid-island-monument-human-01",
        "raid-island-monument-human-02",
        "raid-island-monument-human-03"
    ),
    "raidMonumentZombie" to listOf(
        "raid-island-monument-zombie-01",
        "raid-island-monument-zombie-02",
        "raid-island-monument-zombie-03"
    ),

    // Arena
    "stadium" to listOf(
        "exterior-stadium-1-no-spawn",
        "exterior-stadium-3-no-spawn",
        "exterior-stadium-5-no-spawn",
        "exterior-stadium-6-no-spawn",
        "exterior-stadium-7-no-spawn",
        "exterior-stadium-8-no-spawn",
        "exterior-stadium-9-no-spawn",
        "exterior-stadium-10-no-spawn",
        "exterior-stadium-11-no-spawn"
    ),
)
