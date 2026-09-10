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
  final List<TextEditingController> _urlControllers = [];
  DateTime? _selectedDate;
  bool _isActive = true;

  bool get isEditing => widget.jobToEdit != null;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.jobToEdit?.companyName);
    _titleController = TextEditingController(text: widget.jobToEdit?.jobTitle);
    _descriptionController = TextEditingController(text: widget.jobToEdit?.description);
    if (widget.jobToEdit != null && widget.jobToEdit!.applicationUrls.isNotEmpty) {
      for (final url in widget.jobToEdit!.applicationUrls) {
        _urlControllers.add(TextEditingController(text: url));
      }
    } else {
      _urlControllers.add(TextEditingController());
    }
    _selectedDate = widget.jobToEdit?.lastDate;
    _isActive = widget.jobToEdit?.isActive ?? true;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _urlControllers) {
      controller.dispose();
    }
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

      final urls = _urlControllers
          .map((c) => c.text.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      if (urls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide at least one valid application URL')),
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
                applicationUrls: urls,
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
                applicationUrls: urls,
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
            context.read<JobBloc>().add(const LoadJobsRequested());
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

                // Application URLs
                const Text(
                  'Application URLs',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                ..._urlControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              labelText: 'Link ${index + 1}',
                              prefixIcon: const Icon(Icons.link_outlined),
                            ),
                            validator: (value) {
                              if (index == 0 && (value == null || value.trim().isEmpty)) {
                                return 'At least one URL is required';
                              }
                              if (value != null && value.trim().isNotEmpty) {
                                final uri = Uri.tryParse(value.trim());
                                if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                                  return 'Enter a valid URL';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_urlControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                            onPressed: () {
                              setState(() {
                                _urlControllers[index].dispose();
                                _urlControllers.removeAt(index);
                              });
                            },
                          ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _urlControllers.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Link'),
                  ),
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
