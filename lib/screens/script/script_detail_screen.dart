import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../models/script_model.dart';
import '../../providers/scripts_provider.dart';
import '../../widgets/error_message.dart';

class ScriptDetailScreen extends StatefulWidget {
  const ScriptDetailScreen({super.key, required this.script});

  final ScriptModel script;

  @override
  State<ScriptDetailScreen> createState() => _ScriptDetailScreenState();
}

class _ScriptDetailScreenState extends State<ScriptDetailScreen> {
  late ScriptModel _script;
  late final TextEditingController _titleController;
  late final TextEditingController _topicController;
  late final TextEditingController _hookController;
  late final TextEditingController _bodyController;
  late final TextEditingController _ctaController;
  late final TextEditingController _fullScriptController;
  late final TextEditingController _hashtagsController;
  late String _platform;
  late bool _isEditing;

  static const _platforms = ['YouTube', 'Instagram Reels', 'TikTok'];

  @override
  void initState() {
    super.initState();
    _script = widget.script;
    _titleController = TextEditingController(text: _script.title);
    _topicController = TextEditingController(text: _script.topic);
    _hookController = TextEditingController(text: _script.hook);
    _bodyController = TextEditingController(text: _script.body);
    _ctaController = TextEditingController(text: _script.cta);
    _fullScriptController = TextEditingController(text: _script.fullScript);
    _hashtagsController = TextEditingController(text: _script.hashtags);
    _platform = _script.platform;
    _isEditing = _script.id == null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _hookController.dispose();
    _bodyController.dispose();
    _ctaController.dispose();
    _fullScriptController.dispose();
    _hashtagsController.dispose();
    super.dispose();
  }

  ScriptModel _scriptFromFields() {
    final fullScript = _fullScriptController.text.trim().isEmpty
        ? [
            _hookController.text.trim(),
            _bodyController.text.trim(),
            _ctaController.text.trim(),
          ].where((part) => part.isNotEmpty).join('\n\n')
        : _fullScriptController.text.trim();

    return _script.copyWith(
      title: _titleController.text.trim().isEmpty
          ? 'Untitled script'
          : _titleController.text.trim(),
      topic: _topicController.text.trim(),
      platform: _platform,
      hook: _hookController.text.trim(),
      body: _bodyController.text.trim(),
      cta: _ctaController.text.trim(),
      fullScript: fullScript,
      hashtags: _hashtagsController.text.trim(),
    );
  }

  Future<void> _save() async {
    final provider = context.read<ScriptsProvider>();
    final next = _scriptFromFields();
    if (next.id == null) {
      final saved = await provider.saveScript(next);
      if (saved != null && mounted) {
        setState(() {
          _script = saved;
          _isEditing = false;
        });
        _showSnack('Script saved');
      }
      return;
    }

    final ok = await provider.updateScript(next);
    if (ok && mounted) {
      setState(() {
        _script = next;
        _isEditing = false;
      });
      _showSnack('Script updated');
    }
  }

  Future<void> _delete() async {
    final id = _script.id;
    if (id == null) {
      Navigator.of(context).pop();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete script?'),
        content: const Text('This removes the saved script from Firestore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final ok = await context.read<ScriptsProvider>().deleteScript(id);
    if (ok && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScriptsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_script.id == null ? 'Generated Script' : 'Script Detail'),
        actions: [
          IconButton(
            tooltip: _isEditing ? 'Preview' : 'Edit',
            onPressed: provider.isSaving
                ? null
                : () => setState(() => _isEditing = !_isEditing),
            icon: Icon(
              _isEditing ? Icons.visibility_outlined : Icons.edit_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: provider.isSaving ? null : _delete,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (provider.errorMessage != null) ...[
                    ErrorMessage(
                      message: provider.errorMessage!,
                      onDismiss: provider.clearError,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_isEditing) _buildEditForm() else _buildPreview(context),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton.icon(
            onPressed: provider.isSaving ? null : _save,
            icon: provider.isSaving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              provider.isSaving
                  ? 'Saving...'
                  : _script.id == null
                  ? 'Save Script'
                  : 'Save Changes',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _script.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.dark,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaPill(
              icon: Icons.smart_display_outlined,
              label: _script.platform,
            ),
            _MetaPill(icon: Icons.topic_outlined, label: _script.topic),
          ],
        ),
        const SizedBox(height: 18),
        _ScriptSection(
          title: 'Hook',
          text: _script.hook,
          icon: Icons.bolt_outlined,
        ),
        _ScriptSection(
          title: 'Body',
          text: _script.body,
          icon: Icons.notes_outlined,
        ),
        _ScriptSection(
          title: 'CTA',
          text: _script.cta,
          icon: Icons.ads_click_outlined,
        ),
        _ScriptSection(
          title: 'Full Script',
          text: _script.fullScript,
          icon: Icons.article_outlined,
        ),
        _ScriptSection(
          title: 'Hashtags',
          text: _script.hashtags,
          icon: Icons.tag,
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _topicController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Topic'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _platforms.contains(_platform)
              ? _platform
              : _platforms.first,
          items: _platforms
              .map(
                (platform) => DropdownMenuItem<String>(
                  value: platform,
                  child: Text(platform),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _platform = value);
            }
          },
          decoration: const InputDecoration(labelText: 'Platform'),
        ),
        const SizedBox(height: 12),
        _EditingField(controller: _hookController, label: 'Hook', minLines: 3),
        const SizedBox(height: 12),
        _EditingField(controller: _bodyController, label: 'Body', minLines: 6),
        const SizedBox(height: 12),
        _EditingField(controller: _ctaController, label: 'CTA', minLines: 3),
        const SizedBox(height: 12),
        _EditingField(
          controller: _fullScriptController,
          label: 'Full Script',
          minLines: 8,
        ),
        const SizedBox(height: 12),
        _EditingField(
          controller: _hashtagsController,
          label: 'Hashtags',
          minLines: 2,
        ),
      ],
    );
  }
}

class _EditingField extends StatelessWidget {
  const _EditingField({
    required this.controller,
    required this.label,
    required this.minLines,
  });

  final TextEditingController controller;
  final String label;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines + 8,
      decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
    );
  }
}

class _ScriptSection extends StatelessWidget {
  const _ScriptSection({
    required this.title,
    required this.text,
    required this.icon,
  });

  final String title;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.dark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              text.isEmpty ? 'No content yet.' : text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.dark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
