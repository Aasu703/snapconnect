import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:snapconnect/common/common.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/features/events/data/repositories/event_repository_impl.dart';
import 'package:snapconnect/features/events/domain/entities/event_entity.dart';
import 'package:uuid/uuid.dart';

/// Create Event screen with premium styling, date/time pickers,
/// and Cloudinary cover image upload support.
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (i) => chars[(rng + i * 7) % chars.length]).join();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    final user = context.read<SessionCubit>().state;
    if (user == null) {
      AppSnackBar.showError(context, AppStrings.pleaseSignInFirst);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      DateTime? eventDate;
      if (_selectedDate != null) {
        final time = _selectedTime ?? TimeOfDay.now();
        eventDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          time.hour,
          time.minute,
        );
      }

      final event = EventEntity(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        hostId: user.id,
        hostName: user.name,
        joinCode: _generateJoinCode(),
        eventDate: eventDate,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        isActive: true,
        createdAt: DateTime.now(),
      );

      final repo = EventRepositoryImpl();
      await repo.createEvent(event);

      if (!mounted) return;
      context.go('/events');
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Failed to create event: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.screenBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: context.colors.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create Event',
          style: TextStyle(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Event Name ───────────────────────────────────────
              _buildLabel('Event Name'),
              const Gap(8),
              _buildTextField(
                controller: _nameController,
                hint: 'Birthday Bash 2026',
                icon: Icons.celebration_rounded,
                validator: (v) => (v ?? '').trim().length < 2
                    ? 'Name must be at least 2 characters'
                    : null,
              ),
              const Gap(20),
              // ── Description ──────────────────────────────────────
              _buildLabel('Description (optional)'),
              const Gap(8),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Pool party, bring your best dance moves!',
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const Gap(20),
              // ── Date & Time ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Date'),
                        const Gap(8),
                        _DateTimeChip(
                          icon: Icons.calendar_today_rounded,
                          label: _selectedDate != null
                              ? DateFormat.yMMMd().format(_selectedDate!)
                              : 'Pick date',
                          onTap: _pickDate,
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Time'),
                        const Gap(8),
                        _DateTimeChip(
                          icon: Icons.access_time_rounded,
                          label: _selectedTime != null
                              ? _selectedTime!.format(context)
                              : 'Pick time',
                          onTap: _pickTime,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(20),
              // ── Location ─────────────────────────────────────────
              _buildLabel('Location (optional)'),
              const Gap(8),
              _buildTextField(
                controller: _locationController,
                hint: 'Central Park, NYC',
                icon: Icons.location_on_outlined,
              ),
              const Gap(36),
              // ── Submit Button ────────────────────────────────────
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF6C63FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isSubmitting ? null : _submit,
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.rocket_launch_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Create Event',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Builder(
      builder: (context) => Text(
        text,
        style: TextStyle(
          color: context.appColors.mutedText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Builder(
      builder: (context) => TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(color: context.colors.onSurface, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: context.appColors.mutedText.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: context.appColors.mutedText,
          ),
          filled: true,
          fillColor: context.appColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: context.appColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: context.appColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
        ),
      ),
    );
  }
}

class _DateTimeChip extends StatelessWidget {
  const _DateTimeChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: context.appColors.mutedText),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: context.colors.onSurface,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
