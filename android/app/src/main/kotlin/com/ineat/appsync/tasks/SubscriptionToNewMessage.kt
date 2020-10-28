package com.ineat.appsync.tasks

import android.os.Handler
import android.os.Looper
import com.amazonaws.mobileconnectors.appsync.AWSAppSyncClient
import com.amazonaws.mobileconnectors.appsync.AppSyncSubscriptionCall
import com.apollographql.apollo.api.Response
import com.apollographql.apollo.exception.ApolloException
import com.google.gson.Gson
import com.ineat.appsync.AppSyncPlugin
import com.ineat.appsync.SubscribeToNewMessageSubscription
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Task for execute the subscription SubscribeToNewMessage in GraphQL file
 * <pre>
 * subscription SubscribeToNewMessage {
 *  subscribeToNewMessage {
 *      id
 *      content
 *      sender
 *  }
 * }
 * </pre>
 */
class SubscriptionToNewMessage(private val client: AWSAppSyncClient, private val call: MethodCall, private val channel: MethodChannel) {
    operator fun invoke() {
        val patientId = call.argument<String>("patientId")
        val doctorId = call.argument<String>("doctorId")
        val subscription = SubscribeToNewMessageSubscription.builder()
                   .patientId(patientId.toString())
                   .doctorId(doctorId.toString())
                   .build()
        val subscriber = client.subscribe(subscription)
        subscriber.execute(object : AppSyncSubscriptionCall.Callback<SubscribeToNewMessageSubscription.Data> {

            override fun onFailure(e: ApolloException) {
                Handler(Looper.getMainLooper()).post { channel.invokeMethod(AppSyncPlugin.SUBSCRIBE_NEW_MESSAGE_RESULT, null)}
            }

            override fun onResponse(response: Response<SubscribeToNewMessageSubscription.Data>) {
                val newMessage = response.data()?.subscribeToNewMessage()?.let {
                    return@let mapOf(
                            "id" to it.id(),
                            "content" to it.content(),
                            "patientId" to it.patientId(),
                            "doctorId" to it.doctorId(),
                            "type" to it.type(),
                              "author" to it.author()
                    )
                }

                newMessage?.let {
                    val json = Gson().toJson(newMessage)
                    Handler(Looper.getMainLooper()).post {channel.invokeMethod(AppSyncPlugin.SUBSCRIBE_NEW_MESSAGE_RESULT, json)}
                    //result.success(json)
                } ?: run {
                    Handler(Looper.getMainLooper()).post { channel.invokeMethod(AppSyncPlugin.SUBSCRIBE_NEW_MESSAGE_RESULT, null)}
                }
            }

            override fun onCompleted() {
                Handler(Looper.getMainLooper()).post { channel.invokeMethod(AppSyncPlugin.SUBSCRIBE_NEW_MESSAGE_RESULT, null)}
            }

        })
    }

}