package core.model.game.data

import kotlinx.serialization.Serializable

/**
 * Morale effects map.
 * This is a simple typealias to Map<String, Double> to ensure proper JSON serialization.
 * The client expects morale data as a flat object with effect names as keys.
 */
typealias Morale = Map<String, Double>
