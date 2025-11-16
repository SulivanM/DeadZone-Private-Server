import com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar

plugins {
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.ktor)
    alias(libs.plugins.kotlin.plugin.serialization)
}

group = "dev.deadzone"
version = "2025.10.22"

repositories {
    mavenCentral()
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(25))
    }
}

tasks.withType<JavaCompile>().configureEach {
    sourceCompatibility = "17"
    targetCompatibility = "17"
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        freeCompilerArgs.add("-opt-in=kotlin.io.encoding.ExperimentalEncodingApi")
    }
}

application {
    mainClass.set("io.ktor.server.netty.EngineMain")
}

ktor {
    fatJar {
        archiveFileName.set("deadzone-server.jar")
    }
}

tasks.withType<ShadowJar> {
    archiveFileName.set("deadzone-server.jar")
    destinationDirectory.set(file("deploy"))
    manifest {
        attributes["Main-Class"] = "io.ktor.server.netty.EngineMain"
    }
}

val copyGameFiles by tasks.registering(Copy::class) {
    from("static")
    into("deploy/static")
    mustRunAfter(tasks.shadowJar)
}

val copyRunScripts by tasks.registering(Copy::class) {
    from("autorun.bat", "autorun.sh")
    into("deploy")
    mustRunAfter(tasks.shadowJar)
}

tasks.shadowJar {
    finalizedBy(copyGameFiles, copyRunScripts)
}

tasks.named("startShadowScripts") {
    mustRunAfter(copyRunScripts, copyGameFiles)
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
    implementation("org.apache.logging.log4j:log4j-slf4j2-impl:2.23.1")
    implementation("org.apache.logging.log4j:log4j-core:2.23.1")
    implementation(libs.ktor.server.config.yaml)
    implementation("org.mariadb.jdbc:mariadb-java-client:3.4.0")
    implementation("org.jetbrains.exposed:exposed-core:0.50.0")
    implementation("org.jetbrains.exposed:exposed-dao:0.50.0")
    implementation("org.jetbrains.exposed:exposed-jdbc:0.50.0")
    implementation("org.jetbrains.exposed:exposed-kotlin-datetime:0.50.0")
    implementation(libs.library.bcrypt)
    testImplementation(libs.ktor.server.test.host)
    testImplementation(libs.kotlin.test.junit)
}