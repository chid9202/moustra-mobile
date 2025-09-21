import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/users_api.dart';
import 'package:moustra/services/dtos/user_detail_dto.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/widgets/shared/button.dart';
import 'package:moustra/services/clients/api_client.dart';

final usersApi = UsersApi(apiClient);

class UserDetailScreen extends StatefulWidget {
  final String? userUuid;
  final bool isNew;

  const UserDetailScreen({super.key, this.userUuid, this.isNew = false});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedRole = 'User';
  String? _selectedPosition;
  bool _isActive = true;
  bool _isLoading = false;
  UserDetailDto? _user;

  final List<String> _roleOptions = ['User', 'Admin'];
  final List<String> _positionOptions = [
    'Principal Investigator',
    'Professor',
    'Lab Manager',
    'Scientist',
    'Technician',
    'Student',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.userUuid != null) {
      _loadUser();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    if (widget.userUuid == null) return;

    setState(() => _isLoading = true);
    try {
      final user = await usersApi.getUser(widget.userUuid!);
      setState(() {
        _user = user;
        _firstNameController.text = user.user.firstName;
        _lastNameController.text = user.user.lastName;
        _emailController.text = user.user.email;
        _selectedRole = user.role;
        _selectedPosition = user.position;
        _isActive = user.isActive;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (widget.isNew) {
        // Get current user's profile for lab UUID and account UUID
        final profile = profileState.value;
        if (profile == null) {
          throw Exception('Profile not loaded');
        }

        final createUserData = PostUserDetailDto(
          accountUuid: '', // Empty as per the payload example
          email: _emailController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          role: _selectedRole,
          position: _selectedPosition,
          isActive: _isActive,
          lab: profile.labUuid,
        );

        await usersApi.createUser(profile.accountUuid, createUserData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User invited successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to users list
          context.go('/users');
        }
      } else if (widget.userUuid != null) {
        final userData = PutUserDetailDto(
          accountUuid: widget.userUuid,
          email: _emailController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          role: _selectedRole,
          position: _selectedPosition,
          isActive: _isActive,
          accountSetting: _user?.accountSetting,
        );

        await usersApi.updateUser(widget.userUuid!, userData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/users');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Invite User' : 'User Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/users'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Combined Form Fields
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Last name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              border: OutlineInputBorder(),
                            ),
                            items: _roleOptions.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedRole = value!);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String?>(
                            value: _selectedPosition,
                            decoration: const InputDecoration(
                              labelText: 'Position',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Select Position'),
                              ),
                              ..._positionOptions.map((position) {
                                return DropdownMenuItem<String?>(
                                  value: position,
                                  child: Text(position),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedPosition = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() => _isActive = value ?? true);
                          },
                        ),
                        const Text('Active User'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              MoustraButton(
                label: widget.isNew ? 'Create User' : 'Save Changes',
                variant: ButtonVariant.success,
                icon: widget.isNew ? Icons.add : Icons.save,
                fullWidth: true,
                isLoading: _isLoading,
                onPressed: _saveUser,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
