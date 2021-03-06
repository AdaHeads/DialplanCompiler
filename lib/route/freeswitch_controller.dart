part of XmlDialplanGenerator.router;

class FreeswitchController {
  Configuration config;

  FreeswitchController(Configuration this.config);

  /**File extensions that is accepted as sound files.*/
  List<String> audioFormats = ['wav'];

  //TODO Rewrite to use async IO instead of sync.
  void listAudioFiles(HttpRequest request) {
    int receptionId = pathIntParameter(request.uri, 'reception');

    Directory dir = new Directory(path.join(config.audioFolder, '${receptionId}'));
    List<String> listOfFiles = [];
    if(dir.existsSync()) {
      List<FileSystemEntity> files = dir.listSync();
      listOfFiles = files.
          where((FileSystemEntity file) => audioFormats.any((String format) => file.absolute.path.endsWith(format))).
          map((FileSystemEntity file) => file.absolute.path).toList();
    }

    writeAndClose(request, JSON.encode({'files': listOfFiles}));
  }

  void deployPlaylist(HttpRequest request) {
    int playlistId = pathIntParameter(request.uri, 'playlist');

    extractContent(request).then((String content) {
      if(content == null || content.isEmpty) {
        clientError(request, "No date send");
        return new Future.value();
      }

      Map json;
      try {
        json = JSON.decode(content);
      } catch(error) {
        clientError(request, "Malformed json");
        return new Future.value();
      }

      Playlist playlist;
      try {
        playlist = new Playlist.fromJson(json)
          ..id = playlistId;
      } catch(error) {
        clientError(request, "Malformed playlist");
        return new Future.value();
      }

      try {
        String filePath = path.join(config.localStreamPath, '${playlist.id}.xml');
        File file = new File(filePath);

        //The XmlPackage v1.0.0 is deprecated, and it uses carrage-return instead of newlines, for line breaks.
        String compiledPlaylist = generateLocalStream(playlist).toString().replaceAll('\r', '\n');
        return file.writeAsString(compiledPlaylist, mode: FileMode.WRITE, flush: true)
                   .then((_) => writeAndClose(request, JSON.encode({})) );
      } catch(error, stack) {
        logger.error('deployPlaylist url: ${request.uri}, gave Error: "${error}" \n${stack}');
        InternalServerError(request);
      }
    }).catchError((error, stack) {
      logger.error('deployPlaylist url: ${request.uri}, gave Error: "${error}" \n${stack}');
      InternalServerError(request);
    });
  }

  void deletePlaylist(HttpRequest request) {
    int playlistId = pathIntParameter(request.uri, 'playlist');

    String filePath = path.join(config.localStreamPath, '${playlistId}.xml');
    File file = new File(filePath);

    file.delete()
        .then((_) => allOk(request))
        .catchError((error) =>serverError(request, 'Deleting playlist ${playlistId} failed. Error: ${error}'));
  }

  void deleteAudioFile(HttpRequest request) {
    String filePath = request.uri.queryParameters['filepath'];

    if(filePath == null || filePath.trim().isEmpty) {
      clientError(request, 'Missing parameter. filepath');
      return;
    }

    File file = new File(filePath);
    file.delete().then((_) {
      allOk(request);
    }).catchError((error) {
      String logMessage = 'Tried deleting file: [${filePath}]. Error: ${error}';
      serverError(request, logMessage);
    });
  }
}
