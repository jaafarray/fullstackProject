import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../util/color_resources.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class MediaListScreen extends StatefulWidget {
  const MediaListScreen({super.key});

  @override
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  Future<List<dynamic>> _fetchMedia(String token) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/api/media/');
    final res = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
    if (res.statusCode >= 400) {
      // Try to surface server message
      try {
        final body = jsonDecode(res.body);
        if (body is Map && body['message'] is String) {
          throw Exception(body['message']);
        }
      } catch (_) {}
      throw Exception('Failed to load media (${res.statusCode})');
    }
    final body = jsonDecode(res.body);
    if (body is Map && body['data'] is List) {
      return body['data'] as List<dynamic>;
    }
    // Fallback if API not wrapped
    if (body is List) return body;
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final token = context.read<AuthProvider>().accessToken ?? '';
    return Scaffold(
      backgroundColor: ColorResources.navyBlueBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Media',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchMedia(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load media',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Text('No media yet', style: TextStyle(color: Colors.white70)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final m = items[index] as Map<String, dynamic>;
              final type = (m['file_type'] ?? '').toString();
              final url = (m['file'] ?? '').toString();
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: type == 'image'
                    ? _ImageTile(url: url)
                    : _AudioTile(url: url),
              );
            },
          );
        },
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final resolved = url.startsWith('http') ? url : '${ApiClient.baseUrl}$url';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, top: 8),
            child: Text('IMAGE', style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              resolved,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 180,
                child: Center(child: Text('Failed to load image', style: TextStyle(color: Colors.white70))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioTile extends StatefulWidget {
  const _AudioTile({required this.url});
  final String url;

  @override
  State<_AudioTile> createState() => _AudioTileState();
}

class _AudioTileState extends State<_AudioTile> {
  late final AudioPlayer _player = AudioPlayer(
    userAgent: 'media_uploader/1.0',
  );
  bool _isPlaying = false;
  bool _initialized = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolved = widget.url.startsWith('http') ? widget.url : '${ApiClient.baseUrl}${widget.url}';
    return ListTile(
      leading: const Icon(Icons.audiotrack_outlined, color: Colors.white),
      title: const Text('AUDIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(resolved, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
      trailing: IconButton(
        icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.white),
        onPressed: () async {
          try {
            if (!_initialized) {
              final session = await AudioSession.instance;
              await session.configure(const AudioSessionConfiguration.music());
              _initialized = true;
            }
            if (_isPlaying) {
              await _player.pause();
              setState(() => _isPlaying = false);
            } else {
              _player.playerStateStream.listen((state) {
                if (state.processingState == ProcessingState.completed) {
                  if (mounted) setState(() => _isPlaying = false);
                }
              });
              // Ensure properly encoded URL and pass light headers
              final uri = Uri.parse(resolved);
              await _player.setAudioSource(
                AudioSource.uri(
                  uri,
                  headers: const {
                    'Accept': 'audio/*,application/octet-stream',
                    'Connection': 'close',
                  },
                ),
              );
              await _player.play();
              setState(() => _isPlaying = true);
            }
          } on PlayerException catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Audio error: ${e.message ?? 'Failed to play'} (code: ${e.code})')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Audio error: ${e.toString()}')),
              );
            }
          }
        },
      ),
    );
  }
}


