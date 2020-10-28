package com.ineat.appsync.tasks

import com.amazonaws.mobileconnectors.appsync.AWSAppSyncClient
import com.amazonaws.mobileconnectors.appsync.fetcher.AppSyncResponseFetchers
import com.apollographql.apollo.GraphQLCall
import com.apollographql.apollo.api.Response
import com.apollographql.apollo.exception.ApolloException
import com.google.gson.Gson
import com.ineat.appsync.GetMessagesQuery
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Task for execute the query GetAllMessages in GraphQL file
 * <pre>
 * "query GetMessages($toUser: String!, $sender: String!) {\n"
+ "  getMessages(toUser: $toUser, sender: $sender) {\n"
+ "    __typename\n"
+ "    id\n"
+ "    content\n"
+ "    toUser\n"
+ "    sender\n"
+ "  }\n"
+ "}";
 * </pre>
 */
class GetAllMessages (private val client: AWSAppSyncClient, private val call: MethodCall, private val result: MethodChannel.Result) {

    operator fun invoke() {
        val patientId = call.argument<String>("patientId")
        val doctorId = call.argument<String>("doctorId")
        val query = GetMessagesQuery.builder()
                .patientId(patientId.toString())
                .doctorId(doctorId.toString())
                .build()
        client.query(query)
                .responseFetcher(AppSyncResponseFetchers.NETWORK_ONLY)
                .enqueue(object : GraphQLCall.Callback<GetMessagesQuery.Data>() {

                    override fun onResponse(response: Response<GetMessagesQuery.Data>) {
                        parseResponse(response)
                    }

                    override fun onFailure(e: ApolloException) {
                        result.error("onFailure", e.message, null)
                    }

                })
    }

    private fun parseResponse(response: Response<GetMessagesQuery.Data>) {
        if (response.hasErrors().not()) {
            val messages = response.data()?.messages?.map {
                return@map mapOf(
                        "id" to it.id(),
                        "content" to it.content(),
                        "patientId" to it.patientId(),
                        "doctorId" to it.doctorId(),
                        "type" to it.type(),
                        "author" to it.author()

                )
            }

            messages?.let {
                val json = Gson().toJson(messages)
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