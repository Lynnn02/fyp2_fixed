import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/note_content.dart';
import 'document_element_widget.dart';

class NoteElementCard extends StatelessWidget {
  final NoteContentElement element;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteElementCard({
    Key? key,
    required this.element,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Element header with type indicator and actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _getHeaderColor(),
            child: Row(
              children: [
                Icon(
                  _getTypeIcon(),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTypeName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Drag handle
                const Icon(
                  Icons.drag_handle,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Edit',
                  onPressed: onEdit,
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          
          // Element content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildElementContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildElementContent() {
    if (element is TextElement) {
      return TextElementWidget(element: element as TextElement);
    } else if (element is ImageElement) {
      return ImageElementWidget(element: element as ImageElement);
    } else if (element is AudioElement) {
      return AudioElementWidget(element: element as AudioElement);
    } else if (element is DocumentElement) {
      return DocumentElementWidget(element: element as DocumentElement);
    }
    return const SizedBox.shrink();
  }
  
  Color _getHeaderColor() {
    if (element is TextElement) {
      return Colors.blue;
    } else if (element is ImageElement) {
      return Colors.green;
    } else if (element is AudioElement) {
      return Colors.purple;
    } else if (element is DocumentElement) {
      return Colors.orange;
    }
    return Colors.grey;
  }
  
  IconData _getTypeIcon() {
    if (element is TextElement) {
      return Icons.text_fields;
    } else if (element is ImageElement) {
      return Icons.image;
    } else if (element is AudioElement) {
      return Icons.audiotrack;
    } else if (element is DocumentElement) {
      return Icons.insert_drive_file;
    }
    return Icons.help_outline;
  }
  
  String _getTypeName() {
    if (element is TextElement) {
      return 'Text';
    } else if (element is ImageElement) {
      return 'Image';
    } else if (element is AudioElement) {
      return 'Audio';
    } else if (element is DocumentElement) {
      return 'Document';
    }
    return 'Unknown';
  }
}

class TextElementWidget extends StatelessWidget {
  final TextElement element;

  const TextElementWidget({
    Key? key,
    required this.element,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
      fontSize: element.fontSize ?? 16,
      color: element.textColor != null ? Color(int.parse(element.textColor!)) : null,
    );
    
    if (element.isList) {
      final lines = element.content.split('\n');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          if (line.trim().isEmpty) return const SizedBox(height: 8);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(child: Text(line, style: style)),
              ],
            ),
          );
        }).toList(),
      );
    }
    
    return Text(element.content, style: style);
  }
}

class ImageElementWidget extends StatelessWidget {
  final ImageElement element;

  const ImageElementWidget({
    Key? key,
    required this.element,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            element.imageUrl,
            width: element.width,
            height: element.height,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        if (element.caption != null && element.caption!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            element.caption!,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}

class AudioElementWidget extends StatefulWidget {
  final AudioElement element;

  const AudioElementWidget({
    Key? key,
    required this.element,
  }) : super(key: key);

  @override
  _AudioElementWidgetState createState() => _AudioElementWidgetState();
}

class _AudioElementWidgetState extends State<AudioElementWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initAudioPlayer() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await _audioPlayer.setUrl(widget.element.audioUrl);
      _audioPlayer.durationStream.listen((duration) {
        if (duration != null && mounted) {
          setState(() {
            _duration = duration;
          });
        }
      });
      
      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });
      
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
              _audioPlayer.seek(Duration.zero);
              _audioPlayer.pause();
            }
          });
        }
      });
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error initializing audio player: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.element.title != null && widget.element.title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.element.title!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Row(
                      children: [
                        // Play/pause button
                        IconButton(
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                            if (_isPlaying) {
                              _audioPlayer.pause();
                            } else {
                              _audioPlayer.play();
                            }
                          },
                          iconSize: 36,
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 8),
                        // Audio progress
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SliderTheme(
                                data: SliderThemeData(
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                  trackHeight: 4,
                                  activeTrackColor: Colors.purple,
                                  inactiveTrackColor: Colors.purple.withOpacity(0.3),
                                  thumbColor: Colors.purple,
                                ),
                                child: Slider(
                                  min: 0,
                                  max: _duration.inMilliseconds.toDouble(),
                                  value: _position.inMilliseconds.toDouble().clamp(
                                    0,
                                    _duration.inMilliseconds.toDouble(),
                                  ),
                                  onChanged: (value) {
                                    _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatDuration(_position)),
                                    Text(_formatDuration(_duration)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
