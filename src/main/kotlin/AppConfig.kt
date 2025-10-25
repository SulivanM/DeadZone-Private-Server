package dev.deadzone

object AppConfig {
    lateinit var gameHost: String
    var gamePort: Int = 7777

    fun initialize(host: String, port: Int) {
        gameHost = host
        gamePort = port
    }
}
