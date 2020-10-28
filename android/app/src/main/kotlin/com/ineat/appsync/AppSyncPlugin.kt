package com.ineat.appsync

import android.os.Handler
import android.os.Looper
import com.amazonaws.mobile.config.AWSConfiguration
import com.amazonaws.mobileconnectors.appsync.AWSAppSyncClient
import com.amazonaws.mobileconnectors.appsync.AppSyncSubscriptionCall
import com.amazonaws.mobileconnectors.appsync.sigv4.BasicAPIKeyAuthProvider
import com.amazonaws.regions.Regions
import com.apollographql.apollo.api.Response
import com.apollographql.apollo.exception.ApolloException
import com.google.gson.Gson
import com.ineat.appsync.tasks.GetAllMessages
import com.ineat.appsync.tasks.NewMessage
import com.ineat.appsync.tasks.SubscriptionToNewMessage
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry


/**
 * Plugin to call GraphQL requests generated from the schema
 */
class AppSyncPlugin private constructor(private val registrar: PluginRegistry.Registrar, private val channel: MethodChannel) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.ineat.appsync"
        const val QUERY_GET_ALL_MESSAGES = "getAllMessages"
        const val MUTATION_NEW_MESSAGE = "newMessage"
        const val SUBSCRIBE_NEW_MESSAGE = "subscribeNewMessage"
        const val SUBSCRIBE_NEW_MESSAGE_RESULT = "subscribeNewMessageResult"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            val instance = AppSyncPlugin(registrar, channel)
            channel.setMethodCallHandler(instance)
        }
    }

    // MethodChannel.Result wrapper that responds on the platform thread.
    class MethodResultWrapper constructor(private val methodResult: Result) : Result {
        private val handler: Handler
        override fun success(result: Any?) {
            handler.post { methodResult.success(result) }
        }

        override fun error(
                errorCode: String, errorMessage: String?, errorDetails: Any?) {
            handler.post { methodResult.error(errorCode, errorMessage, errorDetails) }
        }

        override fun notImplemented() {
            handler.post { methodResult.notImplemented() }
        }

        init {
            handler = Handler(Looper.getMainLooper())
        }
    }

    /**
     * Client AWS AppSync for call GraphQL requests
     */
    var client: AWSAppSyncClient? = null
    override fun onMethodCall(call: MethodCall, rawResult: MethodChannel.Result) {
        val result: Result = MethodResultWrapper(rawResult)
        prepareClient(call)
        onPerformMethodCall(call, result)
    }

    /**
     * Handle type method. Call task for run GraphQL request
     */
    private fun onPerformMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            QUERY_GET_ALL_MESSAGES -> GetAllMessages(client!!, call, result)()
            MUTATION_NEW_MESSAGE -> NewMessage(client!!, call, result)()
            SUBSCRIBE_NEW_MESSAGE -> SubscriptionToNewMessage(client!!, call, channel)()
            else -> result.notImplemented()
        }
    }

    /**
     * Create AWS AppSync Client if not exist
     */
    private fun prepareClient(call: MethodCall) {
        val endpoint = call.argument<String>("endpoint")
        val apiKey = call.argument<String>("apiKey")
        if (client == null) {

            val awsConfig = AWSConfiguration(registrar.context().applicationContext)
            client = AWSAppSyncClient.builder()
                    .context(registrar.context().applicationContext)
                    //.apiKey(BasicAPIKeyAuthProvider(apiKey))
                    //.region(Regions.US_EAST_2)
                    //.serverUrl(endpoint)
                    .awsConfiguration(awsConfig)
                    .build()
        }
    }

}