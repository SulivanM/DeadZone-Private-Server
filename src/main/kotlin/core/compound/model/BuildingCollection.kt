package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class BuildingCollection(
    val list: List<BuildingLike> = listOf()
) {
    companion object {
        fun starterBase(): List<BuildingLike> {
            // player starter junks, based on compound.xml; id based on name.
            val junks = listOf(
                JunkBuilding(name = "junk", type = "junk-tutorial", pos = "-650,950,-1", rot = "0,0,0"),
                JunkBuilding(name = "junk1", type = "junk-pile-corner", pos = "-927,-1026,0", rot = "0,0,90"),
                JunkBuilding(name = "junk2", type = "junk-drums", pos = "-974,-323,0", rot = "0,0,90"),
                JunkBuilding(name = "junk3", type = "junk-machinery-small", pos = "1150,1150,0", rot = "0,0,0"),
                JunkBuilding(name = "junk4", type = "junk-pile-corner", pos = "-950,1150,0", rot = "0,0,0"),
                JunkBuilding(name = "junk5", type = "junk-pile-mid", pos = "-950,-639,0", rot = "0,0,180"),
                JunkBuilding(name = "junk6", type = "junk-machinery-large", pos = "-1050,150,0", rot = "0,0,270"),
                JunkBuilding(name = "junk7", type = "junk-pallets", pos = "-850,550,0", rot = "0,0,0"),
                JunkBuilding(name = "junk9", type = "junk-drums", pos = "-550,1150,0", rot = "0,0,0"),
                JunkBuilding(name = "junk11", type = "junk-drums", pos = "462,-1116,0", rot = "0,0,220"),
                JunkBuilding(name = "junk12", type = "junk-pile-small", pos = "950,-550,-1", rot = "0,0,180"),
                JunkBuilding(name = "junk14", type = "junk-pile-mid", pos = "650,-950,0", rot = "0,0,270"),
                JunkBuilding(name = "junk15", type = "junk-pallets", pos = "1048,-350,0", rot = "0,0,155"),
                JunkBuilding(name = "junk16", type = "junk-pile-mid", pos = "950,850,0", rot = "0,0,0"),
                JunkBuilding(name = "junk17", type = "junk-pallets", pos = "151,1161,0", rot = "0,0,270"),
                JunkBuilding(name = "junk20", type = "junk-machinery-small", pos = "1060,-1196,0", rot = "0,0,270"),
                JunkBuilding(name = "junk-outside-1", type = "junk-pile-small", pos = "950,-1950,-1", rot = "0,0,35"),
                JunkBuilding(name = "junk-outside-2", type = "junk-pallets", pos = "1214,-1984,0", rot = "0,0,0"),
                JunkBuilding(name = "junk-outside-3", type = "junk-pile-mid", pos = "1450,-1050,0", rot = "0,0,265"),
                JunkBuilding(name = "junk-outside-4", type = "junk-pile-car", pos = "1541,952,0", rot = "0,0,0"),
                JunkBuilding(name = "junk-outside-5", type = "junk-pile-small", pos = "1450,1850,-1", rot = "0,0,65"),
                JunkBuilding(name = "junk-outside-6", type = "junk-drums", pos = "1351,2149,0", rot = "0,0,90"),
                JunkBuilding(name = "junkCloth1", type = "junk-cloth", pos = "1420,-639,0", rot = "0,0,0"),
                JunkBuilding(name = "junkCloth2", type = "junk-cloth", pos = "-750,2750,0", rot = "0,0,180"),
                JunkBuilding(name = "junkCloth3", type = "junk-cloth", pos = "-850,-2350,0", rot = "0,0,90"),
                JunkBuilding(name = "junkCloth4", type = "junk-cloth", pos = "450,-450,0", rot = "0,0,0"),
                JunkBuilding(name = "junk-outside-25", type = "junk-pile-mid", pos = "2250,-52,0", rot = "0,0,0"),
                JunkBuilding(name = "junk-outside-26", type = "junk-pile-small", pos = "2350,2451,0", rot = "0,0,0"),
                JunkBuilding(name = "junk-outside-27", type = "junk-pile-mid", pos = "-450,-1650,0", rot = "0,0,0"),
                JunkBuilding(name = "junk-outside-wood-1", type = "junk-pallets", pos = "3392,2987,0", rot = "0,0,0"),
                JunkBuilding(name = "junk-outside-metal-1", type = "junk-drums", pos = "3550,-3050,0", rot = "0,0,0"),
                JunkBuilding(name = "junk-huge-1", type = "junk-pile-huge", pos = "2521,-2201,0", rot = "0,0,0"),
                JunkBuilding(name = "junk-huge-2", type = "junk-pile-huge-2", pos = "2441,-1635,0", rot = "0,0,0"),
                JunkBuilding(name = "junk-pile-huge-1-2", type = "junk-pile-huge", pos = "320,1982,0", rot = "0,0,180"),
                JunkBuilding(name = "junk-pile-huge-2-2", type = "junk-pile-huge-2", pos = "2600,1366,0", rot = "0,0,90"),
            )

            return buildList {
                addAll(junks)
                // defaults building
                add(Building(type = "rally", tx = 15, ty = 33, rotation = 0))
                add(Building(type = "bed", tx = 15, ty = 42, rotation = 0))
                add(Building(type = "car", tx = 35, ty = 50, rotation = 0))
            }
        }

        fun simpleBase(): List<BuildingLike> {
            return listOf(
                Building(type = "bed", tx = 19, ty = 35, level = 2, rotation = 3),
                Building(type = "storage-ammunition", tx = 11, ty = 47, level = 5, rotation = 2),
                Building(type = "storage-cloth", tx = 12, ty = 38, level = 5, rotation = 0),
                Building(type = "storage-water", tx = 16, ty = 42, level = 5, rotation = 0),
                Building(type = "storage-metal", tx = 12, ty = 44, level = 5, rotation = 0),
                Building(type = "recycler", tx = 21, ty = 40, level = 9, rotation = 1),
                Building(type = "compound-barricade-small", tx = 17, ty = 62, level = 0, rotation = 3),
                Building(type = "compound-barricade-small", tx = 20, ty = 61, level = 0, rotation = 0),
                Building(type = "compound-barricade-small", tx = 15, ty = 59, level = 0, rotation = 2),
                Building(type = "compound-barricade-small", tx = 31, ty = 46, level = 0, rotation = 3),
                Building(type = "compound-barricade-small", tx = 33, ty = 42, level = 0, rotation = 1),
                Building(type = "compound-barricade-small", tx = 34, ty = 45, level = 0, rotation = 0),
                Building(type = "compound-barricade-small", tx = 18, ty = 29, level = 0, rotation = 0),
                Building(type = "compound-barricade-small", tx = 17, ty = 26, level = 0, rotation = 1),
                Building(type = "compound-barricade-small", tx = 14, ty = 27, level = 0, rotation = 2),
                Building(type = "deadend", tx = 31, ty = 51, level = 0, rotation = 0),
                Building(type = "deadend", tx = 32, ty = 38, level = 0, rotation = 0),
                Building(type = "deadend", tx = 25, ty = 60, level = 0, rotation = 3),
                Building(type = "rally", tx = 18, ty = 60, level = 0, rotation = 3),
                Building(type = "rally", tx = 32, ty = 44, level = 0, rotation = 0),
                Building(type = "rally", tx = 16, ty = 24, level = 0, rotation = 1),
            )
        }

        fun goodBase(): List<BuildingLike> {
            return listOf(
                // inside
                Building(type = "bed", tx = 9, ty = 46, level = 4, rotation = 0),
                Building(type = "bed", tx = 9, ty = 43, level = 4, rotation = 0),
                Building(type = "bed", tx = 9, ty = 40, level = 4, rotation = 0),
                Building(type = "shower", tx = 15, ty = 50, level = 4, rotation = 0),
                Building(type = "shower", tx = 18, ty = 50, level = 4, rotation = 0),
                Building(type = "storage-ammunition", tx = 15, ty = 42, level = 5, rotation = 0),
                Building(type = "storage-ammunition", tx = 18, ty = 42, level = 5, rotation = 0),
                Building(type = "storage-cloth", tx = 7, ty = 34, level = 5, rotation = 3),
                Building(type = "storage-cloth", tx = 24, ty = 34, level = 5, rotation = 3),
                Building(type = "storage-water", tx = 8, ty = 55, level = 5, rotation = 0),
                Building(type = "storage-water", tx = 8, ty = 52, level = 5, rotation = 0),
                Building(type = "storage-metal", tx = 27, ty = 55, level = 5, rotation = 0),
                Building(type = "storage-metal", tx = 24, ty = 55, level = 5, rotation = 0),
                Building(type = "recycler", tx = 14, ty = 34, level = 9, rotation = 0),
                Building(type = "workbench", tx = 14, ty = 45, level = 4, rotation = 3),
                Building(type = "bench-engineering", tx = 19, ty = 34, level = 4, rotation = 3),
                Building(type = "bench-weapon", tx = 19, ty = 44, level = 4, rotation = 0),

                // right side
                Building(type = "barricadeSmall", tx = 13, ty = 28, level = 4, rotation = 2),
                Building(type = "barricadeSmall", tx = 15, ty = 27, level = 4, rotation = 1),
                Building(type = "barricadeSmall", tx = 18, ty = 27, level = 4, rotation = 1),
                Building(type = "barricadeSmall", tx = 18, ty = 30, level = 4, rotation = 0),
                Building(type = "door", tx = 17, ty = 57, level = 4, rotation = 3),
                Building(type = "rally", tx = 16, ty = 24, level = 0, rotation = 1),

                // outer right side
                Building(type = "defence-wire", tx = 26, ty = 15, level = 3, rotation = 1),
                Building(type = "defence-wire", tx = 32, ty = 15, level = 3, rotation = 1),
                Building(type = "defence-wire", tx = 38, ty = 15, level = 3, rotation = 1),
                Building(type = "defence-wire", tx = 38, ty = 21, level = 3, rotation = 0),
                Building(type = "defence-wire", tx = 38, ty = 27, level = 3, rotation = 0),
                Building(type = "windmill", tx = 33, ty = 20, level = 4, rotation = 1),
                Building(type = "trap-halloween-decoy", tx = 10, ty = 14, level = 0, rotation = 1),
                Building(type = "trap-halloween-decoy", tx = 8, ty = 14, level = 0, rotation = 1),

                // front side
                Building(type = "barricadeSmall", tx = 32, ty = 35, level = 4, rotation = 1),
                Building(type = "barricadeSmall", tx = 35, ty = 35, level = 4, rotation = 1),
                Building(type = "barricadeLarge", tx = 30, ty = 57, level = 4, rotation = 3),
                Building(type = "barricadeLarge", tx = 36, ty = 57, level = 4, rotation = 3),
                Building(type = "barricadeLarge", tx = 41, ty = 56, level = 4, rotation = 0),
                Building(type = "barricadeLarge", tx = 41, ty = 47, level = 4, rotation = 0),
                Building(type = "barricadeLarge", tx = 41, ty = 41, level = 4, rotation = 0),
                Building(type = "barricadeLarge", tx = 41, ty = 35, level = 4, rotation = 1),
                Building(type = "watchtower", tx = 31, ty = 53, level = 3, rotation = 3),
                Building(type = "watchtower", tx = 33, ty = 39, level = 3, rotation = 0),
                Building(type = "gate", tx = 41, ty = 50, level = 4, rotation = 0),
                Building(type = "deadend", tx = 37, ty = 50, level = 0, rotation = 0),
                Building(type = "deadend", tx = 37, ty = 38, level = 0, rotation = 0),
                Building(type = "rally", tx = 32, ty = 44, level = 0, rotation = 0),

                // left side
                Building(type = "barricadeLarge", tx = 14, ty = 58, level = 4, rotation = 2),
                Building(type = "barricadeLarge", tx = 15, ty = 63, level = 4, rotation = 3),
                Building(type = "barricadeLarge", tx = 21, ty = 63, level = 4, rotation = 0),
                Building(type = "construction-yard", tx = 28, ty = 59, level = 4, rotation = 1),
                Building(type = "door", tx = 16, ty = 31, level = 4, rotation = 1),
                Building(type = "deadend", tx = 18, ty = 67, level = 0, rotation = 3),
                Building(type = "rally", tx = 17, ty = 59, level = 0, rotation = 3),
            )
        }
    }
}
