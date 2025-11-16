package server.tasks

/**
 * Represents a category of tasks that correspond to implementations of [ServerTask].
 *
 * Each high-level category of tasks inherits from [TaskCategory], while subcategories
 * (specific task types within a category) inherit from their respective parent category.
 */
sealed interface TaskCategory {
    /**
     * Unique code to identify this task category, typically used to derive task ID.
     */
    val code: String

    object TimeUpdate : TaskCategory {
        override val code: String = "TU"
    }

    sealed interface Building : TaskCategory {
        object Create : Building {
            override val code: String = "BLD-CREATE"
        }

        object Repair : Building {
            override val code: String = "BLD-REPAIR"
        }

        object Upgrade : Building {
            override val code: String = "BLD-UPGRADE"
        }
    }

    sealed interface Mission : TaskCategory {
        object Return : Mission {
            override val code: String = "MIS-RETURN"
        }
    }

    sealed interface Task : TaskCategory {
        object JunkRemoval : Task {
            override val code: String = "TASK-JUNK"
        }
    }

    sealed interface BatchRecycle : TaskCategory {
        object Complete : BatchRecycle {
            override val code: String = "BATCH-RECYCLE"
        }
    }
}
