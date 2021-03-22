import 'package:dart_mercure/src/dart_mercure_auth_client.dart';
import 'package:eventsource/eventsource.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class Mercure {
  final String hub_url;
  final String token;
  http.Client client;

  Mercure({@required this.hub_url, @required this.token, http.Client client})
      : assert(hub_url != null),
        assert(token != null) {
    this.client = client ?? http.Client();
    this.client = AuthClient(token, this.client);
  }

  /// Subscribe to one mercure topic
  Future<void> subscribeTopic({@required String topic,
    @required void Function(Event event) onData,
    Function onError,
    void Function() onDone,
    bool cancelOnError}) async {
    await subscribeTopics(
        topics: <String>[topic],
        onData: onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError);
  }

  /// Subscribe to a list of mercure topics
  Future<void> subscribeTopics({@required List<String> topics,
    @required void Function(Event event) onData,
    Function onError,
    void Function() onDone,
    bool cancelOnError}) async {
    var params = topics.map((topic) => 'topic=$topic&').join();
    params = params.substring(0, params.length - 1);
    var eventSource;
    try {
      eventSource = await EventSource.connect(
          '$hub_url?$params&Last-Event-ID=true', client: this.client);
      eventSource.listen(onData, onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError);
    } catch (e) {
      throw e;
    }
  }

  /// Publish data in mercure topic
  Future<int> publish({@required String topic, @required String data}) async {
    var response = await this.client.post(hub_url,
        body: {'topic': topic, 'data': data});
    return response.statusCode;
  }
}
