import com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar

plugins {
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.ktor)
    alias(libs.plugins.kotlin.plugin.serialization)
}

group = "dev.deadzone"
version = "2025.07.11"

repositories {
    mavenCentral()
}

application {
    mainClass = "io.ktor.server.netty.EngineMain"
}

ktor {
    fatJar {
        archiveFileName.set("deadzone-server.jar")
    }
}

tasks.withType<ShadowJar> {
    destinationDirectory.set(file("deploy"))
    manifest {
        attributes["Main-Class"] = "io.ktor.server.netty.EngineMain"
    }
}

tasks.register<Copy>("copyRunScripts") {
    from("autorun.bat", "autorun.sh")
    into("deploy")
}

tasks.named("shadowJar") {
    finalizedBy("copyRunScripts")
}

dependencies {
    implementation(libs.ktor.network.tls)
    implementation(libs.ktor.server.core)
    implementation(libs.ktor.server.websockets)
    implementation(libs.ktor.server.content.negotiation)
	implementation(libs.ktor.serialization.kotlinx.protobuf)
	implementation(libs.ktor.serialization.kotlinx.json)
    implementation(libs.ktor.server.call.logging)
    implementation(libs.ktor.server.host.common)
    implementation(libs.ktor.server.status.pages)
    implementation(libs.ktor.server.cors)
    implementation(libs.ktor.server.netty)
    implementation(libs.logback.classic)
    implementation(libs.ktor.server.config.yaml)
    implementation(libs.mongodb.driver.kotlin.coroutine)
    implementation(libs.mongodb.bson.kotlinx)
    implementation(libs.library.bcrypt)
    testImplementation(libs.ktor.server.test.host)
    testImplementation(libs.kotlin.test.junit)
}
