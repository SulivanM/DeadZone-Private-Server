package core.data.parser

import core.data.resources.CostTable
import core.data.resources.SpeedUpConfig
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import utils.Logger
import java.io.File

object CostTableParser {
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    fun parse(file: File): CostTable {
        if (!file.exists()) {
            Logger.warn { "Cost table file not found: ${file.path}, using defaults" }
            return CostTable()
        }

        try {
            val jsonContent = file.readText()
            val jsonElement = json.parseToJsonElement(jsonContent).jsonObject

            return CostTable(
                speedUpOneHour = parseSpeedUpConfig(jsonElement, "SpeedUpOneHour"),
                speedUpTwoHour = parseSpeedUpConfig(jsonElement, "SpeedUpTwoHour"),
                speedUpHalf = parseSpeedUpConfig(jsonElement, "SpeedUpHalf"),
                speedUpComplete = parseSpeedUpConfig(jsonElement, "SpeedUpComplete"),
                speedUpFree = parseSpeedUpConfig(jsonElement, "SpeedUpFree")
            )
        } catch (e: Exception) {
            Logger.error { "Failed to parse cost_table.json: ${e.message}" }
            return CostTable()
        }
    }

    private fun parseSpeedUpConfig(jsonObject: kotlinx.serialization.json.JsonObject, key: String): SpeedUpConfig {
        val configObj = jsonObject[key]?.jsonObject ?: return SpeedUpConfig()

        return SpeedUpConfig(
            type = configObj["type"]?.jsonPrimitive?.content ?: "",
            order = configObj["order"]?.jsonPrimitive?.content?.toIntOrNull() ?: 0,
            enabled = configObj["enabled"]?.jsonPrimitive?.content?.toBooleanStrictOrNull() ?: true,
            key = configObj["key"]?.jsonPrimitive?.content ?: key,
            time = configObj["time"]?.jsonPrimitive?.content?.toIntOrNull(),
            maxTime = configObj["maxTime"]?.jsonPrimitive?.content?.toIntOrNull(),
            percent = configObj["percent"]?.jsonPrimitive?.content?.toDoubleOrNull(),
            costPerMin = configObj["costPerMin"]?.jsonPrimitive?.content?.toDoubleOrNull() ?: 0.0,
            minCost = configObj["minCost"]?.jsonPrimitive?.content?.toIntOrNull() ?: 0,
            priceCoins = configObj["PriceCoins"]?.jsonPrimitive?.content?.toIntOrNull() ?: 0
        )
    }
}
