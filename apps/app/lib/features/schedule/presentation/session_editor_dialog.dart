import 'package:fitness_app/core/api_error.dart';
import 'package:fitness_app/core/confirm_delete.dart';
import 'package:fitness_app/core/locale_controller.dart';
import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:fitness_app/features/users/application/users_providers.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

Future<void> showSessionEditor({
  required BuildContext context,
  required WidgetRef ref,
  Map<String, dynamic>? session,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => SessionEditorDialog(session: session),
  );
  if (saved == true) {
    invalidateStudioWeek(ref);
  }
}

class SessionEditorDialog extends ConsumerStatefulWidget {
  const SessionEditorDialog({super.key, this.session});

  final Map<String, dynamic>? session;

  @override
  ConsumerState<SessionEditorDialog> createState() => _SessionEditorDialogState();
}

class _SessionEditorDialogState extends ConsumerState<SessionEditorDialog> {
  final _room = TextEditingController();
  final _capacity = TextEditingController();
  final _duration = TextEditingController(text: '60');

  List<Map<String, dynamic>> _types = [];
  List<Map<String, dynamic>> _people = [];
  String? _classTypeId;
  String? _trainerId;
  late DateTime _starts;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.session != null;

  int get _bookedCount {
    final session = widget.session;
    if (session == null) {
      return 0;
    }
    return (session['bookedCount'] as num?)?.toInt() ??
        ((session['bookings'] as List<dynamic>?)?.length ?? 0);
  }

  @override
  void initState() {
    super.initState();
    final session = widget.session;
    if (session != null) {
      final starts = DateTime.parse(session['startsAt'] as String).toLocal();
      final ends = DateTime.parse(session['endsAt'] as String).toLocal();
      _starts = starts;
      final minutes = ends.difference(starts).inMinutes;
      _duration.text = (minutes > 0 ? minutes : 60).toString();
      _classTypeId = session['classTypeId'] as String? ??
          (session['classType'] as Map<String, dynamic>?)?['id'] as String?;
      _room.text = session['room'] as String? ?? '';
      _capacity.text = (session['capacity'] as num?)?.toInt().toString() ?? '8';
      _trainerId = session['trainerId'] as String? ??
          (session['trainer'] as Map<String, dynamic>?)?['id'] as String?;
    } else {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      _starts = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10);
      _capacity.text = '8';
      _room.text = '';
    }
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    final types = await ref.read(studioRepositoryProvider).classTypes();
    var people = <Map<String, dynamic>>[];
    try {
      final rows = await ref.read(usersRepositoryProvider).list();
      people = [
        for (final row in rows)
          if (row['user'] is Map<String, dynamic>) row['user'] as Map<String, dynamic>,
      ];
    } catch (_) {}
    if (!mounted) {
      return;
    }
    setState(() {
      _types = types;
      _people = people;
      _classTypeId ??= types.isEmpty ? null : types.first['id'] as String;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _room.dispose();
    _capacity.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _starts,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _starts = DateTime(picked.year, picked.month, picked.day, _starts.hour, _starts.minute);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_starts),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _starts = DateTime(_starts.year, _starts.month, _starts.day, picked.hour, picked.minute);
    });
  }

  Map<String, dynamic>? _body(AppLocalizations l10n) {
    final typeId = _classTypeId;
    final capacity = int.tryParse(_capacity.text.trim());
    final minutes = int.tryParse(_duration.text.trim());
    if (typeId == null || capacity == null || capacity < 1 || minutes == null || minutes < 1) {
      _error = l10n.checkSessionFields;
      return null;
    }
    if (capacity < _bookedCount) {
      _error = l10n.capacityBelowBooked(_bookedCount);
      return null;
    }
    final ends = _starts.add(Duration(minutes: minutes));
    return {
      'classTypeId': typeId,
      'startsAt': _starts.toUtc().toIso8601String(),
      'endsAt': ends.toUtc().toIso8601String(),
      'capacity': capacity,
      if (_room.text.trim().isNotEmpty) 'room': _room.text.trim(),
      if (_trainerId != null) 'trainerId': _trainerId,
    };
  }

  Future<void> _save() async {
    setState(() {
      _error = null;
      _saving = true;
    });
    final body = _body(AppLocalizations.of(context));
    if (body == null) {
      setState(() => _saving = false);
      return;
    }
    try {
      final repo = ref.read(studioRepositoryProvider);
      if (_isEdit) {
        await repo.updateSession(widget.session!['id'] as String, body);
      } else {
        await repo.createSession(body);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = _apiMessage(e, AppLocalizations.of(context));
        _saving = false;
      });
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final sure = await confirmDelete(
      context,
      title: l10n.deleteSessionTitle,
      message: l10n.deleteSessionMessage,
    );
    if (sure != true || !mounted) {
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      await ref.read(studioRepositoryProvider).deleteSession(widget.session!['id'] as String);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = _apiMessage(e, AppLocalizations.of(context));
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loc = (ref.watch(localeControllerProvider).valueOrNull ?? const Locale('ru')).toString();
    final dateFmt = DateFormat('EEE d MMM y', loc);
    final timeFmt = DateFormat('HH:mm', loc);
    return AlertDialog(
      title: Text(_isEdit ? l10n.sessionTitle : l10n.newSession),
      content: SizedBox(
        width: 420,
        child: _loading
            ? const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()))
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_types.isEmpty)
                      Text(l10n.noClassTypes)
                    else
                      InputDecorator(
                        decoration: InputDecoration(labelText: l10n.classType),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _classTypeId,
                            items: [
                              for (final t in _types)
                                DropdownMenuItem(
                                  value: t['id'] as String,
                                  child: Text(t['name'] as String),
                                ),
                            ],
                            onChanged: _saving ? null : (v) => setState(() => _classTypeId = v),
                          ),
                        ),
                      ),
                    InputDecorator(
                      decoration: InputDecoration(labelText: l10n.trainer),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _trainerId ?? '',
                          items: [
                            DropdownMenuItem(value: '', child: Text(l10n.noTrainer)),
                            if (_trainerId != null && !_people.any((p) => p['id'] == _trainerId))
                              DropdownMenuItem(
                                value: _trainerId,
                                child: Text(
                                  (widget.session?['trainer'] as Map<String, dynamic>?)?['name']
                                          as String? ??
                                      l10n.trainer,
                                ),
                              ),
                            for (final person in _people)
                              DropdownMenuItem(
                                value: person['id'] as String,
                                child: Text(person['name'] as String? ?? ''),
                              ),
                          ],
                          onChanged: _saving
                              ? null
                              : (v) => setState(() => _trainerId = (v == null || v.isEmpty) ? null : v),
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.date),
                      subtitle: Text(dateFmt.format(_starts)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _saving ? null : _pickDate,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.startTime),
                      subtitle: Text(timeFmt.format(_starts)),
                      trailing: const Icon(Icons.schedule),
                      onTap: _saving ? null : _pickTime,
                    ),
                    TextField(
                      controller: _duration,
                      enabled: !_saving,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l10n.durationMin),
                    ),
                    TextField(
                      controller: _room,
                      enabled: !_saving,
                      decoration: InputDecoration(labelText: l10n.room),
                    ),
                    TextField(
                      controller: _capacity,
                      enabled: !_saving,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l10n.capacity,
                        helperText: _bookedCount > 0 ? l10n.bookedCount(_bookedCount) : null,
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ),
                  ],
                ),
              ),
      ),
      actions: [
        if (_isEdit)
          TextButton(
            onPressed: _saving ? null : _delete,
            child: Text(l10n.delete),
          ),
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.dismiss),
        ),
        FilledButton(
          onPressed: _saving || _types.isEmpty ? null : _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

String _apiMessage(Object error, AppLocalizations l10n) {
  return switch (apiErrorCode(error)) {
    'SESSION_HAS_BOOKINGS' => l10n.sessionHasBookings,
    'CAPACITY_BELOW_BOOKED' => l10n.capacityBelowBookedShort,
    'INVALID_SESSION_RANGE' => l10n.invalidSessionRange,
    'CLASS_TYPE_NOT_FOUND' => l10n.classTypeNotFound,
    'TRAINER_NOT_FOUND' => l10n.trainerNotFound,
    _ => l10n.saveFailed,
  };
}
