import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scripts_provider.dart';
import '../../widgets/error_message.dart';
import '../script/script_detail_screen.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  String _platform = 'YouTube';

  static const _platforms = ['YouTube', 'Instagram Reels', 'TikTok'];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      return;
    }

    final script = await context.read<ScriptsProvider>().generateScript(
      userId: user.uid,
      topic: _topicController.text,
      platform: _platform,
    );

    if (script != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ScriptDetailScreen(script: script)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scripts = context.watch<ScriptsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Script')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'What are you making today?',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.dark,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a platform and describe the topic, niche, product, or idea.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 20),
                    if (scripts.errorMessage != null) ...[
                      ErrorMessage(
                        message: scripts.errorMessage!,
                        onDismiss: scripts.clearError,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _topicController,
                      minLines: 4,
                      maxLines: 8,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        labelText: 'Topic',
                        alignLabelWithHint: true,
                        hintText:
                            'Example: 5 mistakes new creators make on TikTok',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 8) {
                          return 'Add a little more detail for a better script';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SegmentedButton<String>(
                      segments: _platforms
                          .map(
                            (platform) => ButtonSegment<String>(
                              value: platform,
                              label: Text(platform),
                              icon: Icon(_iconForPlatform(platform)),
                            ),
                          )
                          .toList(),
                      selected: {_platform},
                      onSelectionChanged: scripts.isGenerating
                          ? null
                          : (value) => setState(() => _platform = value.first),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: scripts.isGenerating ? null : _generate,
                      icon: scripts.isGenerating
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        scripts.isGenerating ? 'Generating...' : 'Generate',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForPlatform(String platform) {
    return switch (platform) {
      'YouTube' => Icons.smart_display_outlined,
      'Instagram Reels' => Icons.movie_creation_outlined,
      _ => Icons.music_video_outlined,
    };
  }
}
