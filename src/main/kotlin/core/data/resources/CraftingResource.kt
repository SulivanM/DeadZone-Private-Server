package core.data.resources

data class CraftingResource(
    val id: String,
    val type: String,
    val limited: Boolean = false,
    val limitStart: String? = null,
    val limitEnd: String? = null,
    val result: CraftingResult,
    val recipe: CraftingRecipe,
    val cost: Int
)

data class CraftingResult(
    val itemType: String,
    val level: Int
)

data class CraftingRecipe(
    val items: List<CraftingIngredient> = emptyList(),
    val buildings: List<BuildingRequirement> = emptyList()
)

data class CraftingIngredient(
    val id: String,
    val quantity: Int
)
