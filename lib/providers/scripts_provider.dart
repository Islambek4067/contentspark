import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/script_model.dart';
import '../services/gemini_service.dart';
import '../services/firestore_service.dart';

class ScriptsProvider extends ChangeNotifier {
  ScriptsProvider({
    GeminiService? geminiService,
    FirestoreService? firestoreService,
  }) : _geminiService = geminiService ?? GeminiService(),
       _firestoreService = firestoreService ?? FirestoreService();

  final GeminiService _geminiService;
  final FirestoreService _firestoreService;

  bool _isGenerating = false;
  bool _isSaving = false;
  String? _errorMessage;

  bool get isGenerating => _isGenerating;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Stream<List<ScriptModel>> scriptsForUser(String userId) {
    return _firestoreService.getUserScripts(userId);
  }

  Future<ScriptModel?> generateScript({
    required String userId,
    required String topic,
    required String platform,
  }) async {
    _setGenerating(true);
    try {
      final generated = await _geminiService.generateScript(
        topic: topic.trim(),
        platform: platform,
      );
      _errorMessage = null;
      return ScriptModel(
        userId: userId,
        title: _titleFromTopic(topic),
        topic: topic.trim(),
        platform: platform,
        hook: generated['hook'] ?? '',
        body: generated['body'] ?? '',
        cta: generated['cta'] ?? '',
        fullScript: generated['fullScript'] ?? '',
        hashtags: generated['hashtags'] ?? '',
        createdAt: DateTime.now(),
      );
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _setGenerating(false);
    }
  }

  Future<ScriptModel?> saveScript(ScriptModel script) async {
    _setSaving(true);
    try {
      final id = await _firestoreService.saveScript(script);
      _errorMessage = null;
      return script.copyWith(id: id);
    } catch (error) {
      _errorMessage = _cleanError(error);
      return null;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> updateScript(ScriptModel script) async {
    if (script.id == null) {
      _errorMessage = 'This script has not been saved yet.';
      notifyListeners();
      return false;
    }
    _setSaving(true);
    try {
      await _firestoreService.updateScript(script.id!, script.toMap());
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> deleteScript(String scriptId) async {
    _setSaving(true);
    try {
      await _firestoreService.deleteScript(scriptId);
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _titleFromTopic(String topic) {
    final cleanTopic = topic.trim();
    if (cleanTopic.length <= 42) {
      return cleanTopic;
    }
    return '${cleanTopic.substring(0, 39)}...';
  }

  String _cleanError(Object error) {
    if (error is FirebaseException) {
      return error.message ?? error.code;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _setGenerating(bool value) {
    _isGenerating = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }
}
