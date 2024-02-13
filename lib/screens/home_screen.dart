import 'package:flutter/material.dart';
import 'package:streamlive/services/api_service.dart';

import '../model/channel_model.dart';
import '../model/video_model.dart';
import 'video_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  Channel? channell;

  @override
  void initState() {
    super.initState();
    initChannel();
  }

  initChannel() async {
    Channel channel = await APIService.instance
        .fetchChannel(channelId: 'UCvAPtgrGuzGy9tCpJViQwhQ');

    setState(() {
      channell = channel;
    });
  }

  buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      height: MediaQuery.of(context).size.height / 8,
      decoration: const BoxDecoration(
          color: Colors.amber,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 1),
              blurRadius: 6.0,
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              //backgroundColor: Colors.white,
              radius: 40,
              backgroundImage: NetworkImage(channell!.profilePictureUrl!),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    channell!.title!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${channell!.subscriberCount!} subscribers',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  buildVideo(Video video) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoScreen(id: video.id!),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        height: MediaQuery.of(context).size.height / 4,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          image: DecorationImage(
              image: NetworkImage(video.thumbnailUrl!), fit: BoxFit.cover),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 1),
              blurRadius: 6.0,
            ),
          ],
        ),
      ),
    );
  }

  loadMoreVideos() async {
    isLoading = true;
    List<Video> moreVideos = await APIService.instance
        .fetchVideosFromPlaylist(playlistId: channell!.uploadPlaylistId!);
    List<Video> allVideos = channell!.videos!..addAll(moreVideos);
    setState(() {
      channell!.videos = allVideos;
    });
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Tela TV',
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      // ignore: unnecessary_null_comparison
      body: channell != null
          ? NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollDetails) {
                if (!isLoading &&
                    channell!.videos!.length !=
                        int.parse(channell!.videoCount!) &&
                    scrollDetails.metrics.pixels ==
                        scrollDetails.metrics.maxScrollExtent) {
                  loadMoreVideos();
                }
                return false;
              },
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 30.0, left: 10.0, right: 10.0, bottom: 5.0),
                    child: Text(
                      channell!.videos![index].title!,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  );
                },
                itemCount: 1 + channell!.videos!.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return buildProfileInfo();
                  }
                  Video video = channell!.videos![index - 1];
                  return buildVideo(video);
                },
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor, // Red
                ),
              ),
            ),
    );
  }
}
