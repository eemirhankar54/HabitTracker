// lib/screens/add_habit/add_habit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});
  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _form = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _emoji = '⭐';
  String _colorHex = '#7C5CFC';
  int _targetDays = 30;

  final _emojis = [
    '⭐',
    '💧',
    '📚',
    '🏃',
    '🧘',
    '💪',
    '🍎',
    '😴',
    '✍️',
    '🎯',
    '🧠',
    '🎵',
    '🌿',
    '☀️',
    '🚴',
    '🏋️'
  ];
  final _colors = [
    '#7C5CFC',
    '#4EA8DE',
    '#FC5C7C',
    '#4ECB71',
    '#FFC857',
    '#FF6B6B',
    '#48CAE4',
    '#F77F00'
  ];

  Color _hex(String h) =>
      Color(int.parse('FF${h.replaceAll('#', '')}', radix: 16));

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final err = await context.read<HabitProvider>().addHabit(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          iconEmoji: _emoji,
          colorHex: _colorHex,
          targetDays: _targetDays,
        );
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.accent));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<HabitProvider>().isLoading;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.addHabit),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Önizleme
            _preview(),
            const SizedBox(height: 24),

            _label('Alışkanlık Adı'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _dec('Örn: Her gün su iç'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Ad boş olamaz' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            _label('Açıklama (isteğe bağlı)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _dec('Not...'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            _label('İkon'),
            const SizedBox(height: 10),
            _emojiPicker(),
            const SizedBox(height: 20),

            _label('Renk'),
            const SizedBox(height: 10),
            _colorPicker(),
            const SizedBox(height: 20),

            _label('Toplam Hedef: $_targetDays Gün'),
            Slider(
              value: _targetDays.toDouble(),
              min: 1,
              max: 365,
              divisions: 364, // Her bir günün seçilebilmesi için
              activeColor: AppColors.primary,
              inactiveColor: AppColors.surfaceVar,
              onChanged: (v) => setState(() => _targetDays = v.round()),
            ),
            const SizedBox(height: 32),

            // Kaydet butonu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text(AppStrings.save,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _preview() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hex(_colorHex).withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: _hex(_colorHex).withOpacity(0.3), width: 1.5),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _hex(_colorHex).withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(_emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Text(
            _titleCtrl.text.isEmpty ? 'Alışkanlık adı...' : _titleCtrl.text,
            style: TextStyle(
              color: _titleCtrl.text.isEmpty
                  ? AppColors.textHint
                  : AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
      );

  Widget _emojiPicker() => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _emojis.map((e) {
          final sel = e == _emoji;
          return GestureDetector(
            onTap: () => setState(() => _emoji = e),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: sel
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel ? AppColors.primary : AppColors.surfaceVar,
                  width: sel ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(e, style: const TextStyle(fontSize: 22)),
            ),
          );
        }).toList(),
      );

  Widget _colorPicker() => Row(
        children: _colors.map((c) {
          final sel = c == _colorHex;
          final color = _hex(c);
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _colorHex = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: sel ? Colors.white : Colors.transparent, width: 3),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                              color: color.withOpacity(0.5), blurRadius: 8)
                        ]
                      : [],
                ),
              ),
            ),
          );
        }).toList(),
      );

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500));

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.surfaceVar),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      );
}
