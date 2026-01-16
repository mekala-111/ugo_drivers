import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({Key? key}) : super(key: key);

  static String routeName = 'EmergencyContacts';
  static String routePath = '/emergencyContacts';

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<EmergencyContact> contacts = [];
  bool isLoading = true;
  
  // Replace these with actual values from your auth system
  final String baseUrl = 'http://localhost:5000/api/emergency-contacts';
  final int userId = 1; // Get from your auth/session
  final String accessToken = 'your_access_token'; // Get from your auth/session

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          contacts = data.map((json) => EmergencyContact.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load contacts');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Failed to load contacts: $e');
    }
  }

  Future<void> _addOrUpdateContact(EmergencyContact? contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditContactScreen(contact: contact),
      ),
    );

    if (result != null) {
      await _saveContact(result, contact?.id);
    }
  }

  Future<void> _saveContact(EmergencyContact contact, int? existingId) async {
    try {
      final url = existingId != null 
          ? '$baseUrl/$existingId'
          : '$baseUrl/post';
      
      final method = existingId != null ? 'PUT' : 'POST';
      
      final response = await (method == 'POST'
          ? http.post(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Content-Type': 'application/json',
              },
              body: json.encode(contact.toJson()),
            )
          : http.put(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Content-Type': 'application/json',
              },
              body: json.encode(contact.toJson()),
            ));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess(existingId != null ? 'Contact updated' : 'Contact added');
        _loadContacts();
      } else {
        throw Exception('Failed to save contact');
      }
    } catch (e) {
      _showError('Failed to save contact: $e');
    }
  }

  Future<void> _deleteContact(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/$id'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          _showSuccess('Contact deleted');
          _loadContacts();
        } else {
          throw Exception('Failed to delete contact');
        }
      } catch (e) {
        _showError('Failed to delete contact: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contacts.isEmpty
              ? _buildEmptyState()
              : _buildContactsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateContact(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contact_emergency, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Emergency Contacts',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add contacts to call in case of emergency',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: contacts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: contact.isPrimary ? Colors.red : Colors.blue,
              child: Text(
                contact.contactName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Row(
              children: [
                Text(contact.contactName),
                if (contact.isPrimary) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PRIMARY',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.contactPhone),
                Text(
                  contact.contactRelationship,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _addOrUpdateContact(contact);
                } else if (value == 'delete') {
                  _deleteContact(contact.id!);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddEditContactScreen extends StatefulWidget {
  final EmergencyContact? contact;

  const AddEditContactScreen({Key? key, this.contact}) : super(key: key);

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _relationshipController;
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.contactName ?? '');
    _phoneController = TextEditingController(text: widget.contact?.contactPhone ?? '');
    _relationshipController = TextEditingController(text: widget.contact?.contactRelationship ?? '');
    _isPrimary = widget.contact?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final contact = EmergencyContact(
        id: widget.contact?.id,
        userId: 1, // Get from your auth/session
        contactName: _nameController.text,
        contactPhone: _phoneController.text,
        contactRelationship: _relationshipController.text,
        isPrimary: _isPrimary,
      );
      Navigator.pop(context, contact);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.family_restroom),
                hintText: 'e.g., Father, Mother, Spouse',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter relationship';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Primary Contact'),
              subtitle: const Text('This contact will be called first'),
              value: _isPrimary,
              onChanged: (value) {
                setState(() => _isPrimary = value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyContact {
  final int? id;
  final int userId;
  final String contactName;
  final String contactPhone;
  final String contactRelationship;
  final bool isPrimary;

  EmergencyContact({
    this.id,
    required this.userId,
    required this.contactName,
    required this.contactPhone,
    required this.contactRelationship,
    required this.isPrimary,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      userId: json['user_id'],
      contactName: json['contact_name'],
      contactPhone: json['contact_phone'],
      contactRelationship: json['contact_relationship'],
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_relationship': contactRelationship,
      'is_primary': isPrimary,
    };
  }
}