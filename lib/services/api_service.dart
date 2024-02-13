import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:streamlive/utilities/keys.dart';

import '../model/channel_model.dart';
import '../model/video_model.dart';

/* www.googleapi.com/youtube/v3/channels */

class APIService {
  APIService.instantiate();
  static final APIService instance = APIService.instantiate();
  final String baseUrl = "youtube.googleapis.com";
  String nextPageToken = '';

  Future<Channel> fetchChannel({required String channelId}) async {
    Map<String, String> parameters = {
      'part': 'snippet, contentDetails, statistics',
      'id': channelId,
      'key': API_KEY
    };
    Uri uri = Uri.https(
      baseUrl,
      'youtube/v3/channels',
      parameters,
    );

    Map<String, String> headers = {
      HttpHeaders.connectionHeader: 'application/json',
    };

    //obtention du canal
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body)['items'][0];
      Channel channel = Channel.fromMap(data);

      //recherche du premier...

      channel.videos = await fetchVideosFromPlaylist(
          playlistId: channel.uploadPlaylistId.toString());
      return channel;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }

  Future<List<Video>> fetchVideosFromPlaylist(
      {required String playlistId}) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'playlistId': playlistId,
      'maxResults': '8',
      'pageToken': nextPageToken,
      'key': API_KEY,
    };
    Uri uri = Uri.https(
      baseUrl,
      '/youtube/v3/playlistItems',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Playlist Videos
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      nextPageToken = data['nextPageToken'] ?? '';
      List<dynamic> videosJson = data['items'];

      // Fetch first eight videos from uploads playlist
      List<Video> videos = [];
      for (var json in videosJson) {
        videos.add(
          Video.fromMap(json['snippet']),
        );
      }
      return videos;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }
}
