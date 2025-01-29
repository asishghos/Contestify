// First, add these dependencies to pubspec.yaml
/*
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  provider: ^6.1.1
*/

// models/study_group.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final List<String> members;
  final List<String> topics;

  StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.members,
    required this.topics,
  });

  factory StudyGroup.fromMap(Map<String, dynamic> map, String id) {
    return StudyGroup(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      creatorId: map['creatorId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      topics: List<String>.from(map['topics'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'members': members,
      'topics': topics,
    };
  }
}

// services/study_group_service.dart
class StudyGroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createStudyGroup(StudyGroup group) async {
    await _firestore.collection('studyGroups').add(group.toMap());
  }

  Stream<List<StudyGroup>> getStudyGroups() {
    return _firestore.collection('studyGroups').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StudyGroup.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> joinStudyGroup(String groupId, String userId) async {
    await _firestore.collection('studyGroups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId])
    });
  }
}

// screens/study_groups_screen.dart
class StudyGroupsScreen extends StatefulWidget {
  @override
  _StudyGroupsScreenState createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen> {
  final StudyGroupService _studyGroupService = StudyGroupService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _topicsController = TextEditingController();

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Study Group'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Group Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter a description'
                    : null,
              ),
              TextFormField(
                controller: _topicsController,
                decoration:
                    InputDecoration(labelText: 'Topics (comma-separated)'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter topics' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _createGroup,
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createGroup() async {
    if (_formKey.currentState?.validate() ?? false) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final group = StudyGroup(
          id: '',
          name: _nameController.text,
          description: _descriptionController.text,
          creatorId: currentUser.uid,
          members: [currentUser.uid],
          topics:
              _topicsController.text.split(',').map((e) => e.trim()).toList(),
        );

        await _studyGroupService.createStudyGroup(group);
        Navigator.pop(context);

        _nameController.clear();
        _descriptionController.clear();
        _topicsController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Groups'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showCreateGroupDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<StudyGroup>>(
        stream: _studyGroupService.getStudyGroups(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data ?? [];

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(group.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.description),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: group.topics
                            .map((topic) => Chip(
                                  label: Text(topic),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        await _studyGroupService.joinStudyGroup(
                          group.id,
                          currentUser.uid,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Joined group successfully!')),
                        );
                      }
                    },
                    child: Text('Join'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _topicsController.dispose();
    super.dispose();
  }
}
