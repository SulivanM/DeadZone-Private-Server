package core.optimization

import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf
import java.util.zip.Deflater
import java.util.zip.Inflater

/**
 * Optimization utilities for serialization and compression
 */
object SerializationOptimizer {

    /**
     * Compress byte array using DEFLATE algorithm
     * Useful for large payloads
     */
    fun compress(data: ByteArray): ByteArray {
        val deflater = Deflater(Deflater.BEST_SPEED)
        deflater.setInput(data)
        deflater.finish()

        val outputStream = java.io.ByteArrayOutputStream(data.size)
        val buffer = ByteArray(1024)

        while (!deflater.finished()) {
            val count = deflater.deflate(buffer)
            outputStream.write(buffer, 0, count)
        }

        deflater.end()
        return outputStream.toByteArray()
    }

    /**
     * Decompress byte array using INFLATE algorithm
     */
    fun decompress(data: ByteArray): ByteArray {
        val inflater = Inflater()
        inflater.setInput(data)

        val outputStream = java.io.ByteArrayOutputStream(data.size)
        val buffer = ByteArray(1024)

        while (!inflater.finished()) {
            val count = inflater.inflate(buffer)
            outputStream.write(buffer, 0, count)
        }

        inflater.end()
        return outputStream.toByteArray()
    }

    /**
     * Encode and optionally compress data
     * Compression is only applied if it reduces size by at least 20%
     */
    @OptIn(ExperimentalSerializationApi::class)
    inline fun <reified T> encodeOptimized(data: T, enableCompression: Boolean = true): ByteArray {
        val encoded = ProtoBuf.encodeToByteArray(data)

        if (!enableCompression || encoded.size < 1024) {
            return encoded
        }

        val compressed = compress(encoded)
        return if (compressed.size < encoded.size * 0.8) {
            // Compression saved at least 20%, use it
            compressed
        } else {
            // Compression didn't help much, return original
            encoded
        }
    }

    /**
     * Pool of byte arrays for reuse to reduce GC pressure
     */
    private val bufferPool = object {
        private val pool = mutableListOf<ByteArray>()
        private val maxPoolSize = 50
        private val bufferSize = 8192

        fun acquire(): ByteArray {
            return synchronized(pool) {
                if (pool.isNotEmpty()) {
                    pool.removeAt(pool.size - 1)
                } else {
                    ByteArray(bufferSize)
                }
            }
        }

        fun release(buffer: ByteArray) {
            synchronized(pool) {
                if (pool.size < maxPoolSize && buffer.size == bufferSize) {
                    pool.add(buffer)
                }
            }
        }
    }

    /**
     * Acquire a buffer from the pool
     */
    fun acquireBuffer(): ByteArray = bufferPool.acquire()

    /**
     * Release a buffer back to the pool
     */
    fun releaseBuffer(buffer: ByteArray) = bufferPool.release(buffer)
}
