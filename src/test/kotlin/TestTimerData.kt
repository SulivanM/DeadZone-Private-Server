import core.model.game.data.Building
import dev.deadzone.core.model.game.data.TimerData
import dev.deadzone.core.model.game.data.changeLength
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.time.Duration.Companion.hours
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.minutes
import kotlin.time.Duration.Companion.seconds

class TimerDataTest {

    @Test
    fun `speedUpByHalf should halve the duration for even hours`() {
        val originalDuration = 6.hours
        val timer = TimerData.runForDuration(originalDuration)
        val resultTimer = timer.changeLength { it!! / 2 }!!

        val expectedDuration = 3.hours
        assertEquals(expectedDuration, resultTimer.length.seconds)
    }

    @Test
    fun `speedUpByHalf should halve the duration for odd hours correctly`() {
        val originalDuration = 5.hours
        val timer = TimerData.runForDuration(originalDuration)
        val resultTimer = timer.changeLength { it!! / 2 }!!

        // 2.5 hours is 2 hours and 30 minutes
        val expectedDuration = 2.hours + 30.minutes
        assertEquals(expectedDuration, resultTimer.length.seconds)
    }

    @Test
    fun `speedUpByHalf should handle fractional hours correctly`() {
        val originalDuration = (4.123).hours
        val timer = TimerData.runForDuration(originalDuration)

        val resultTimer = timer.changeLength { it!! / 2.0 }!!
        // should be 2h 3m 41.4s but lost to 2h 3m 41s
        val expectedDuration = 2.hours + 3.minutes + 41.seconds
        assertEquals(expectedDuration, resultTimer.length.seconds)
    }

    @Test
    fun `speedUpByHalf should handle mixed units`() {
        val originalDuration = 2.hours + 10.minutes
        val timer = TimerData.runForDuration(originalDuration)
        val resultTimer = timer.changeLength { it!! / 2 }!!

        val expectedDuration = 1.hours + 5.minutes
        assertEquals(expectedDuration, resultTimer.length.seconds)
    }

    @Test
    fun `speedUpHalf on a very short timer should work correctly`() {
        val originalDuration = 3.seconds
        val timer = TimerData.runForDuration(originalDuration)

        val resultTimer = timer.changeLength { it!! / 2.0 }!!

        // should be 1.5 but lost to 1.0
        val expectedDuration = (1).seconds
        assertEquals(expectedDuration, resultTimer.length.seconds)
    }

    @Test
    fun `speedUpHalf on a null timer should return null`() {
        val building = Building(type = "", upgrade = null)
        val resultUpgrade = building.upgrade?.changeLength { it!! / 2 }

        assertEquals(null, resultUpgrade)
    }
}
