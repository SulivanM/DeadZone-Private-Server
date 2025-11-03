import core.survivor.InjuryService
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

class TestInjuryService {

    @Test
    fun testGenerateMinorInjury() {
        val injury = InjuryService.generateInjury(
            severityGroup = "minor",
            cause = "blunt",
            force = true,
            isCritical = false
        )

        assertNotNull(injury)
        assertTrue(injury.severity in listOf("minor", "moderate"))
        assertNotNull(injury.id)
        assertNotNull(injury.timer)
        assertTrue(injury.damage > 0.0)
    }

    @Test
    fun testGenerateMajorInjury() {
        val injury = InjuryService.generateInjury(
            severityGroup = "major",
            cause = "sharp",
            force = true,
            isCritical = false
        )

        assertNotNull(injury)
        assertTrue(injury.severity in listOf("serious", "severe", "critical"))
        assertNotNull(injury.id)
        assertNotNull(injury.timer)
        assertTrue(injury.damage >= 0.4)
    }

    @Test
    fun testGenerateCriticalInjury() {
        val injury = InjuryService.generateInjury(
            severityGroup = "major",
            cause = "bullet",
            force = true,
            isCritical = true
        )

        assertNotNull(injury)
        assertEquals("critical", injury.severity)
        assertNotNull(injury.id)
        assertNotNull(injury.timer)
        assertEquals(0.6, injury.damage)
    }

    @Test
    fun testGenerateInjuryWithoutForce() {
        // Run multiple times to test randomness
        var nullCount = 0
        var injuryCount = 0

        repeat(100) {
            val injury = InjuryService.generateInjury(
                severityGroup = "minor",
                cause = "blunt",
                force = false,
                isCritical = false
            )

            if (injury == null) {
                nullCount++
            } else {
                injuryCount++
            }
        }

        // Both null and non-null results should occur (probabilistic test)
        assertTrue(nullCount > 0, "Expected some null results")
        assertTrue(injuryCount > 0, "Expected some injuries")
    }

    @Test
    fun testValidCause() {
        assertTrue(InjuryService.isValidCause("blunt"))
        assertTrue(InjuryService.isValidCause("sharp"))
        assertTrue(InjuryService.isValidCause("heat"))
        assertTrue(InjuryService.isValidCause("bullet"))
        assertTrue(InjuryService.isValidCause("illness"))
        assertTrue(InjuryService.isValidCause("unknown"))
        assertTrue(!InjuryService.isValidCause("invalid"))
    }

    @Test
    fun testValidSeverityGroup() {
        assertTrue(InjuryService.isValidSeverityGroup("minor"))
        assertTrue(InjuryService.isValidSeverityGroup("major"))
        assertTrue(!InjuryService.isValidSeverityGroup("invalid"))
    }

    @Test
    fun testInjuryHasTimer() {
        val injury = InjuryService.generateInjury(
            severityGroup = "minor",
            cause = "blunt",
            force = true,
            isCritical = false
        )

        assertNotNull(injury)
        assertNotNull(injury.timer)
        assertTrue(injury.timer!!.length > 0)
        assertNotNull(injury.timer!!.data)
        assertEquals("injury", injury.timer!!.data?.get("type"))
    }
}
