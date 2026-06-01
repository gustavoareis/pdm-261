import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

final _authorizationEndpoint = Uri.parse(
  'https://github.com/login/oauth/authorize',
);
final _tokenEndpoint = Uri.parse('https://github.com/login/oauth/access_token');

typedef AuthenticatedBuilder =
    Widget Function(BuildContext context, oauth2.Client client);

class GithubLoginWidget extends StatefulWidget {
  const GithubLoginWidget({
    required this.builder,
    required this.githubClientId,
    required this.githubClientSecret,
    required this.githubScopes,
    super.key,
  });

  final AuthenticatedBuilder builder;
  final String githubClientId;
  final String githubClientSecret;
  final List<String> githubScopes;

  @override
  State<GithubLoginWidget> createState() => _GithubLoginState();
}

class _GithubLoginState extends State<GithubLoginWidget> {
  HttpServer? _redirectServer;
  oauth2.Client? _client;

  @override
  void dispose() {
    _redirectServer?.close();
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = _client;
    if (client != null) {
      return widget.builder(context, client);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('GitHub Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _redirectServer?.close();
            _redirectServer = await HttpServer.bind('localhost', 8080);
            final authenticatedHttpClient = await _getOAuth2Client(
              Uri.parse('http://localhost:${_redirectServer!.port}/auth'),
            );

            setState(() {
              _client = authenticatedHttpClient;
            });
          },
          child: const Text('Login to GitHub'),
        ),
      ),
    );
  }

  Future<oauth2.Client> _getOAuth2Client(Uri redirectUrl) async {
    if (widget.githubClientId.isEmpty ||
        widget.githubClientSecret.isEmpty ||
        widget.githubClientId == 'YOUR_GITHUB_CLIENT_ID_HERE' ||
        widget.githubClientSecret == 'YOUR_GITHUB_CLIENT_SECRET_HERE') {
      throw const GithubLoginException(
        'githubClientId and githubClientSecret must be configured in '
        'lib/github_oauth_credentials.dart.',
      );
    }

    final grant = oauth2.AuthorizationCodeGrant(
      widget.githubClientId,
      _authorizationEndpoint,
      _tokenEndpoint,
      secret: widget.githubClientSecret,
      httpClient: _JsonAcceptingHttpClient(),
    );

    final authorizationUrl = grant.getAuthorizationUrl(
      redirectUrl,
      scopes: widget.githubScopes,
    );
    await _redirect(authorizationUrl);

    final responseQueryParameters = await _listen();
    return grant.handleAuthorizationResponse(responseQueryParameters);
  }

  Future<void> _redirect(Uri authorizationUrl) async {
    if (await canLaunchUrl(authorizationUrl)) {
      await launchUrl(authorizationUrl);
    } else {
      throw GithubLoginException('Could not launch $authorizationUrl');
    }
  }

  Future<Map<String, String>> _listen() async {
    final request = await _redirectServer!.first;
    final params = request.uri.queryParameters;

    request.response.statusCode = 200;
    request.response.headers.set('content-type', 'text/plain');
    request.response.writeln('Authenticated! You can close this tab.');
    await request.response.close();
    await _redirectServer!.close();
    _redirectServer = null;

    return params;
  }
}

class _JsonAcceptingHttpClient extends http.BaseClient {
  final _httpClient = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return _httpClient.send(request);
  }
}

class GithubLoginException implements Exception {
  const GithubLoginException(this.message);

  final String message;

  @override
  String toString() => message;
}
