import 'dart:io';

import 'package:dio/dio.dart';
import 'package:icook_mobile/core/exceptions/network_exception.dart';
import 'package:icook_mobile/core/services/Api/ApiService.dart';
import 'package:icook_mobile/core/utils/file_helper.dart';
import 'package:icook_mobile/core/utils/network_utils.dart' as network_utils;

import '../../../locator.dart';

/// Helper service that abstracts away common HTTP Requests
class ApiServiceImpl implements ApiService {
  final _fileHelper = locator<FileHelper>();

  final _dio = Dio();

  @override
  Future<dynamic> getHttp(String route) async {
    Response response;

    print('Sending GET to $route');

    try {
      final fullRoute = '$route';
      response = await _dio.get(
        fullRoute,
        options: Options(
          contentType: 'application/json',
        ),
      );
    } on DioError catch (e) {
      print('ApiService: Failed to GET ${e.message}');
      throw NetworkException(e.message);
    }

    network_utils.checkForNetworkExceptions(response);
    network_utils.responseHandler(response);

    // For this specific API its decodes json for us
    return response.data;
  }

  @override
  Future<dynamic> postHttp(String route, dynamic body) async {
    Response response;

    print('Sending $body to $route');

    try {
      final fullRoute = '$route';
      response = await _dio.post(
        fullRoute,
        data: body,
        onSendProgress: network_utils.showLoadingProgress,
        onReceiveProgress: network_utils.showLoadingProgress,
        options: Options(
          contentType: 'application/json',
        ),
      );
    } on DioError catch (e) {
      print('HttpService: Failed to POST ${e.message}');
      throw NetworkException(e.message);
    }

    network_utils.checkForNetworkExceptions(response);
    network_utils.responseHandler(response);

    // For this specific API its decodes json for us
    return response.data;
  }

  @override
  Future<dynamic> postHttpForm(
    String route,
    Map<String, dynamic> body,
    List<File> files,
  ) async {
    int index = 0;

    final formData = FormData.fromMap(body);
    files?.forEach((file) async {
      final mFile = await _fileHelper.convertFileToMultipartFile(file);
      formData.files.add(MapEntry('file$index', mFile));
      index++;
    });

    final data = await postHttp(route, formData);

    return data;
  }

  @override
  Future<File> downloadFile(String fileUrl) async {
    Response response;

    final file = await _fileHelper.getFileFromUrl(fileUrl);

    try {
      response = await _dio.download(
        fileUrl,
        file.path,
        onReceiveProgress: network_utils.showLoadingProgress,
      );
    } on DioError catch (e) {
      print('HttpService: Failed to download file ${e.message}');
      throw NetworkException(e.message);
    }

    network_utils.checkForNetworkExceptions(response);
    network_utils.responseHandler(response);

    return file;
  }

  @override
  void dispose() {
    _dio.clear();
    _dio.close(force: true);
  }
}
