import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobnoti/core/constants/app_colors.dart';
import 'package:jobnoti/core/constants/app_spacing.dart';
import 'package:jobnoti/core/common/widgets/primary_button.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_event_state.dart';
import 'package:jobnoti/features/jobs/domain/entities/job_entity.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_event_state.dart';
import 'package:intl/intl.dart';

class AddEditJobPage extends StatefulWidget {
  final JobEntity? jobToEdit;

  const AddEditJobPage({super.key, this.jobToEdit});

  @override
  State<AddEditJobPage> createState() => _AddEditJobPageState();
}

class _AddEditJobPageState extends State<AddEditJobPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlController;
  DateTime? _selectedDate;
  bool _isActive = true;

  bool get isEditing => widget.jobToEdit != null;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.jobToEdit?.companyName);
    _titleController = TextEditingController(text: widget.jobToEdit?.jobTitle);
    _descriptionController = TextEditingController(text: widget.jobToEdit?.description);
    _urlController = TextEditingController(text: widget.jobToEdit?.applicationUrl);
    _selectedDate = widget.jobToEdit?.lastDate;
    _isActive = widget.jobToEdit?.isActive ?? true;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a deadline date')),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) return;

      if (isEditing) {
        context.read<JobBloc>().add(
              UpdateJobRequested(
                jobId: widget.jobToEdit!.id,
                companyName: _companyController.text.trim(),
                jobTitle: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
                applicationUrl: _urlController.text.trim(),
                lastDate: _selectedDate!,
                isActive: _isActive,
              ),
            );
      } else {
        context.read<JobBloc>().add(
              CreateJobRequested(
                companyName: _companyController.text.trim(),
                jobTitle: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
                applicationUrl: _urlController.text.trim(),
                lastDate: _selectedDate!,
                createdBy: authState.user.id,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Job' : 'Create Job'),
      ),
      body: BlocListener<JobBloc, JobState>(
        listener: (context, state) {
          if (state is JobCreated || state is JobUpdated) {
            Navigator.of(context).pop();
          } else if (state is JobError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Company Name
                TextFormField(
                  controller: _companyController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Job Title
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Job Title',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  textInputAction: TextInputAction.newline,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Application URL
                TextFormField(
                  controller: _urlController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Application URL',
                    prefixIcon: Icon(Icons.link_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Required';
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                      return 'Enter a valid URL (e.g. https://...)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Deadline Date Picker
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Deadline Date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : DateFormat.yMMMd().format(_selectedDate!),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Is Active Toggle (Only when editing)
                if (isEditing) ...[
                  SwitchListTile(
                    title: const Text('Is Active'),
                    subtitle: const Text('Hide this job from users without deleting it'),
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                // Submit Button
                BlocBuilder<JobBloc, JobState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: isEditing ? 'Update Job' : 'Post Job',
                      isLoading: state is JobLoading,
                      onPressed: _onSave,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
