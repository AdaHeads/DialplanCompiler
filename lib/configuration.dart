library configuration;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

/**
 * Class for loading configuration file, and configuration from the
 * command-line arguments and check if every thing needed is configurated
 **/
class Configuration {
  ArgResults _args;

  Uri authurl;
  String configfile;
  String localContextPath;
  String publicContextPath;
  String audioFolder;
  String localStreamPath;
  String ivrPath;

  int httpport;

  Configuration(ArgResults args) {
    _args = args;
  }

  void parse() {
    if(_hasArgument('configfile')) {
      configfile = _args['configfile'];
      _parseFile();
    }
    _parseCLA();
    _validate();
  }

  void _parseCLA() {
    if(_hasArgument('authurl')) {
      authurl = Uri.parse(_args['authurl']);
    }

    if(_hasArgument('httpport')) {
      httpport = int.parse(_args['httpport']);
    }

    if(_hasArgument('localcontextpath')) {
      localContextPath = _args['localcontextpath'];
    }

    if(_hasArgument('publiccontextpath')) {
      publicContextPath = _args['publiccontextpath'];
    }

    if(_hasArgument('audiofolder')) {
      audioFolder = _args['audiofolder'];
    }

    if(_hasArgument('localstreampath')) {
      localStreamPath = _args['localstreampath'];
    }

    if(_hasArgument('ivrpath')) {
      ivrPath = _args['ivrpath'];
    }
  }

  void _parseFile() {
    if(configfile == null) {
      return;
    }

    File file = new File(configfile);
    String rawContent = file.readAsStringSync();

    Map content = JSON.decode(rawContent);

    if(content.containsKey('authurl')) {
      authurl = Uri.parse(content['authurl']);
    }

    if(content.containsKey('httpport')) {
      httpport = content['httpport'];
    }

    if(content.containsKey('localcontextpath')) {
      localContextPath = content['localcontextpath'];
    }

    if(content.containsKey('publiccontextpath')) {
      publicContextPath = content['publiccontextpath'];
    }

    if(content.containsKey('audiofolder')) {
      audioFolder = content['audiofolder'];
    }

    if(content.containsKey('localstreampath')) {
      localStreamPath = content['localstreampath'];
    }

    if(content.containsKey('ivrpath')) {
      ivrPath = content['ivrpath'];
    }
  }

  /**
   * Checks if the configuration is valid.
   */
  void _validate() {
    if(localContextPath == null) {
      throw new InvalidConfigurationException("localContextPath isn't specified");
    } else {
      Directory directory = new Directory(localContextPath);
      if(!directory.existsSync()) {
        throw new InvalidConfigurationException('localContextPath: "${localContextPath}" does not exists');
      }
    }

    if(publicContextPath == null) {
      throw new InvalidConfigurationException("publicContextPath isn't specified");
    } else {
      Directory directory = new Directory(publicContextPath);
      if(!directory.existsSync()) {
        throw new InvalidConfigurationException('publicContextPath: "${publicContextPath}" does not exists');
      }
    }

    if(audioFolder == null) {
      throw new InvalidConfigurationException("audiofolder isn't specified");
    } else {
      Directory directory = new Directory(audioFolder);
      if(!directory.existsSync()) {
        throw new InvalidConfigurationException('audiofolder: "${audioFolder}" does not exists');
      }
    }

    if(localStreamPath == null) {
      throw new InvalidConfigurationException("localstreampath isn't specified");
    } else {
      Directory directory = new Directory(localStreamPath);
      if(!directory.existsSync()) {
        throw new InvalidConfigurationException('localstreampath: "${localStreamPath}" does not exists');
      }
    }

    if(ivrPath == null) {
      throw new InvalidConfigurationException("ivrpath isn't specified");
    } else {
      Directory directory = new Directory(ivrPath);
      if(!directory.existsSync()) {
        throw new InvalidConfigurationException('ivrpath: "${ivrPath}" does not exists');
      }
    }
  }

  String toString() => '''
      LocalContextPath: ${localContextPath}
      publicContextPath: ${publicContextPath}
      audioFolder: ${audioFolder}
      localstreampath: ${localStreamPath}
      ivrpath: ${ivrPath}
      HttpPort: $httpport     
      ''';

  bool _hasArgument(String key) {
    assert(_args != null);
    return _args.options.contains(key) && _args[key] != null;
  }
}

class InvalidConfigurationException implements Exception {
  final String msg;
  const InvalidConfigurationException([this.msg]);

  String toString() => msg == null ? 'InvalidConfigurationException' : msg;
}
