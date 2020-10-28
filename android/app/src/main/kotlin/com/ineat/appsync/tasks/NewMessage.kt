package com.ineat.appsync.tasks

import com.amazonaws.mobileconnectors.appsync.AWSAppSyncClient
import com.apollographql.apollo.GraphQLCall
import com.apollographql.apollo.api.Response
import com.apollographql.apollo.exception.ApolloException
import com.google.gson.Gson
import com.ineat.appsync.NewMessageMutation
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Task for execute the mutation NewMessage in GraphQL file
 * <pre>
 * mutation NewMessage($content: String!, $sender: String!, $toUser: String!) {\n"
+ "  newMessage(content: $content, sender: $sender, toUser: $toUser) {\n"
+ "    __typename\n"
+ "    id\n"
+ "    content\n"
+ "    toUser\n"
+ "  }\n"
+ "}"
 * </pre>
 */
class NewMessage(private val client: AWSAppSyncClient, private val call: MethodCall, private val result: MethodChannel.Result) {

    operator fun invoke() {
        val content = call.argument<String>("content")
        val doctorId = call.argument<String>("doctorId")
        val patientId = call.argument<String>("patientId")
        val type = call.argument<String>("type")
        val author = call.argument<String>("author")

        val mutation = NewMessageMutation.builder()
                .content(content.toString())
                .doctorId(doctorId.toString())
                .patientId(patientId.toString())
                .type(type.toString())
                .author(author.toString())
                .build()

        client.mutate(mutation).enqueue(object : GraphQLCall.Callback<NewMessageMutation.Data>() {


            override fun onResponse(response: Response<NewMessageMutation.Data>) {
                parseResponse(response)
            }

            override fun onFailure(e: ApolloException) {
                result.error("onFailure", e.message, null)
            }

        })
    }

    private fun parseResponse(response: Response<NewMessageMutation.Data>) {
        if (response.hasErrors().not()) {
            val newMessage = response.data()?.newMessage()?.let {
                return@let mapOf(
                        "id" to it.id(),
                        "content" to it.content(),
                        "doctorId" to it.doctorId(),
                        "patientId" to it.patientId(),
                        "type" to it.type(),
                        "author" to it.author()
                )
            }

            newMessage?.let {
                val json = Gson().toJson(newMessage)
                result.success(json)
            } ?: run {
                result.success(null)
            }
        } else {
            val error = response.errors().map { it.message() }.joinToString(", ")
            result.error("Errors", error, null)
        }
    }

}