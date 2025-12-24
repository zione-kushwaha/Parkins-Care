import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/emergency_contact.dart';
import '../bloc/tremor_bloc.dart';
import '../bloc/tremor_event.dart';
import '../bloc/tremor_state.dart';

class EmergencyContactsWidget extends StatefulWidget {
  const EmergencyContactsWidget({super.key});

  @override
  State<EmergencyContactsWidget> createState() =>
      _EmergencyContactsWidgetState();
}

class _EmergencyContactsWidgetState extends State<EmergencyContactsWidget> {
  @override
  void initState() {
    super.initState();
    context.read<TremorBloc>().add(LoadEmergencyContacts());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<TremorBloc, TremorState>(
      builder: (context, state) {
        if (state is EmergencyContactsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<EmergencyContact> contacts = [];
        if (state is EmergencyContactsLoaded) {
          contacts = state.contacts;
        }

        return Column(
          children: [
            Expanded(
              child: contacts.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        return _buildContactCard(
                          context,
                          contacts[index],
                          theme,
                          isDark,
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _showAddContactDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Emergency Contact'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contacts, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No emergency contacts',
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Add contacts for quick emergency access',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    EmergencyContact contact,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: contact.isPrimary
            ? Border.all(color: AppColors.primaryBlue, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            contact.isPrimary ? Icons.star : Icons.person,
            color: AppColors.primaryBlue,
            size: 28,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                contact.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (contact.isPrimary)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PRIMARY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 16,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  contact.phoneNumber,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.family_restroom,
                  size: 16,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  contact.relationship,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
              onTap: () {
                Future.delayed(
                  const Duration(milliseconds: 100),
                  () => _showAddContactDialog(context, contact: contact),
                );
              },
            ),
            if (!contact.isPrimary)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.star, size: 20),
                    SizedBox(width: 8),
                    Text('Set as Primary'),
                  ],
                ),
                onTap: () {
                  context.read<TremorBloc>().add(
                    UpdateEmergencyContact(
                      EmergencyContact(
                        id: contact.id,
                        name: contact.name,
                        phoneNumber: contact.phoneNumber,
                        relationship: contact.relationship,
                        isPrimary: true,
                        createdAt: contact.createdAt,
                      ),
                    ),
                  );
                },
              ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () {
                context.read<TremorBloc>().add(
                  DeleteEmergencyContact(contact.id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContactDialog(
    BuildContext context, {
    EmergencyContact? contact,
  }) {
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(
      text: contact?.phoneNumber ?? '',
    );
    final relationshipController = TextEditingController(
      text: contact?.relationship ?? '',
    );
    bool isPrimary = contact?.isPrimary ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    prefixIcon: Icon(Icons.family_restroom),
                    hintText: 'e.g., Spouse, Parent, Sibling',
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: isPrimary,
                  onChanged: (value) {
                    setState(() => isPrimary = value ?? false);
                  },
                  title: const Text('Set as Primary Contact'),
                  subtitle: const Text('Called first during SOS'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    relationshipController.text.isNotEmpty) {
                  final newContact = EmergencyContact(
                    id:
                        contact?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    phoneNumber: phoneController.text.trim(),
                    relationship: relationshipController.text.trim(),
                    isPrimary: isPrimary,
                    createdAt: contact?.createdAt ?? DateTime.now(),
                  );

                  if (contact == null) {
                    this.context.read<TremorBloc>().add(
                      AddEmergencyContact(newContact),
                    );
                  } else {
                    this.context.read<TremorBloc>().add(
                      UpdateEmergencyContact(newContact),
                    );
                  }

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: Text(contact == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
