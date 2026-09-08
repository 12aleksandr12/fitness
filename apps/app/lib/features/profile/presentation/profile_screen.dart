import 'dart:typed_data';

import 'package:fitness_app/core/confirm_delete.dart';
import 'package:fitness_app/core/logout_button.dart';
import 'package:fitness_app/core/permissions.dart';
import 'package:fitness_app/core/require_permission.dart';
import 'package:fitness_app/core/user_avatar.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/features/profile/application/photo_providers.dart';
import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _profile;
  Uint8List? _preview;
  String? _error;
  bool _loading = true;
  bool _saving = false;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ref.read(studioRepositoryProvider).profile(widget.userId);
      if (!mounted) {
        return;
      }
      _name.text = profile['name'] as String? ?? '';
      _phone.text = profile['phone'] as String? ?? '';
      _bio.text = profile['bio'] as String? ?? '';
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context).loadProfileFailed;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final profile = await ref.read(studioRepositoryProvider).updateMyProfile({
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'bio': _bio.text.trim(),
      });
      ref.invalidate(authControllerProvider);
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = profile;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).saved)));
    } catch (_) {
      setState(() {
        _error = AppLocalizations.of(context).saveFailed;
        _saving = false;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );
    if (picked == null) {
      return;
    }
    final bytes = await picked.readAsBytes();
    if (bytes.length > 512 * 1024) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).photoTooLarge);
      }
      return;
    }
    setState(() {
      _saving = true;
      _preview = Uint8List.fromList(bytes);
    });
    try {
      await ref.read(studioRepositoryProvider).uploadMyPhoto(bytes, picked.name);
      ref.invalidate(userPhotoProvider(widget.userId));
      ref.invalidate(authControllerProvider);
      await _load();
    } catch (_) {
      if (mounted) {
        setState(() {
          _preview = null;
          _error = AppLocalizations.of(context).photoType;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _removePhoto() async {
    final l10n = AppLocalizations.of(context);
    final sure = await confirmDelete(
      context,
      title: l10n.deletePhotoTitle,
      message: l10n.deletePhotoMessage,
    );
    if (sure != true || !mounted) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(studioRepositoryProvider).deleteMyPhoto();
      setState(() => _preview = null);
      ref.invalidate(userPhotoProvider(widget.userId));
      ref.invalidate(authControllerProvider);
      await _load();
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).deletePhotoFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSelf = ref.watch(authControllerProvider).valueOrNull?.userId == widget.userId;
    final profile = _profile;
    final hasPhoto = _preview != null || profile?['hasPhoto'] == true;
    final name = profile?['name'] as String? ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelf ? l10n.profile : (name.isEmpty ? l10n.member : name)),
        actions: const [LogoutButton()],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
          ? Center(child: Text(_error ?? l10n.noData))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      UserAvatar(
                        userId: widget.userId,
                        name: name,
                        hasPhoto: hasPhoto,
                        preview: _preview,
                        radius: 48,
                      ),
                      if (isSelf) ...[
                        TextButton(onPressed: _saving ? null : _pickPhoto, child: Text(l10n.choosePhoto)),
                        if (hasPhoto)
                          TextButton(onPressed: _saving ? null : _removePhoto, child: Text(l10n.deletePhoto)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(profile['roleName'] as String? ?? '', textAlign: TextAlign.center),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                const SizedBox(height: 16),
                if (isSelf) ...[
                  TextField(
                    controller: _name,
                    enabled: !_saving,
                    decoration: InputDecoration(labelText: l10n.name),
                  ),
                  TextField(
                    controller: _phone,
                    enabled: !_saving,
                    decoration: InputDecoration(labelText: l10n.phoneOptional),
                  ),
                  TextField(
                    controller: _bio,
                    enabled: !_saving,
                    maxLength: 500,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: l10n.aboutOptional),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.save)),
                ] else ...[
                  ListTile(title: Text(l10n.name), subtitle: Text(name)),
                  if (profile['bio'] != null && (profile['bio'] as String).isNotEmpty)
                    ListTile(title: Text(l10n.about), subtitle: Text(profile['bio'] as String)),
                  if (profile['phone'] != null)
                    ListTile(title: Text(l10n.phone), subtitle: Text(profile['phone'] as String)),
                  if (profile['email'] != null)
                    ListTile(title: Text(l10n.email), subtitle: Text(profile['email'] as String)),
                ],
                if (!isSelf)
                  RequirePermission(
                    slug: Permissions.adjustBalance,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: FilledButton(
                        onPressed: () async {
                          await ref.read(studioRepositoryProvider).adjust(widget.userId, 8, l10n.adjustNote);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.visitsGranted)),
                            );
                          }
                        },
                        child: Text(l10n.grantVisits),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
