import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning/screens/contact.dart';
import 'package:e_learning/screens/course_application_screen.dart';

class Homescreen extends StatelessWidget {
  Homescreen({Key? key}) : super(key: key);

  final CollectionReference applicationsCollection =
      FirebaseFirestore.instance.collection('Applications');

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'User';
    final greetingName = user?.displayName ?? 'there';

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-learning App'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                displayName,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                user?.email ?? 'No email',
                style: const TextStyle(fontSize: 14.0),
              ),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  displayName.isNotEmpty ? displayName[0] : 'U',
                  style: const TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Course Application'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CourseApplicationScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_support),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Hi, $greetingName!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your Applied Courses:',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<DocumentSnapshot>>(
                  future: getCoursesForUser(user!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No courses applied yet.'));
                    } else {
                      List<CourseCard> courseCards = snapshot.data!
                          .map((doc) => CourseCard.fromSnapshot(doc))
                          .toList();
                      return ListView(
                        children: courseCards,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<DocumentSnapshot>> getCoursesForUser(String userId) async {
    QuerySnapshot querySnapshot =
        await applicationsCollection.where('userId', isEqualTo: userId).get();
    return querySnapshot.docs;
  }
}

class CourseCard extends StatelessWidget {
  final String name;
  final String price;
  final String description;
  final String instructor;
  final String duration;
  final String startDate;
  final String experience;
  final String documentId; // Added field for document ID

  CourseCard({
    required this.name,
    required this.price,
    required this.description,
    required this.instructor,
    required this.duration,
    required this.startDate,
    required this.experience,
    required this.documentId, // Initialize in constructor
  });

  factory CourseCard.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return CourseCard(
      name: data['courseName'] ?? '',
      price: data['coursePrice'] ?? '',
      description: data['courseDescription'] ?? '',
      instructor: data['instructorName'] ?? '',
      duration: data['courseDuration'] ?? '',
      startDate: data['preferredStartDate'] ?? '',
      experience: data['previousExperience'] ?? '',
      documentId: snapshot.id, // Assign document ID from snapshot
    );
  }

  void onDelete(BuildContext context) {
    FirebaseFirestore.instance
        .collection('Applications')
        .doc(documentId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete course: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Text('Price: \$$price'),
          const SizedBox(height: 4.0),
          Text(description),
          const SizedBox(height: 4.0),
          Text('Instructor: $instructor'),
          const SizedBox(height: 4.0),
          Text('Duration: $duration'),
          const SizedBox(height: 4.0),
          Text('Start Date: $startDate'),
          const SizedBox(height: 4.0),
          Text('Experience: $experience'),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onDelete(context),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to update screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpdateCourseScreen(docId: documentId),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UpdateCourseScreen extends StatefulWidget {
  final String docId;

  const UpdateCourseScreen({Key? key, required this.docId}) : super(key: key);

  @override
  _UpdateCourseScreenState createState() => _UpdateCourseScreenState();
}

class _UpdateCourseScreenState extends State<UpdateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _instructorController;
  late TextEditingController _durationController;
  late TextEditingController _startDateController;
  late TextEditingController _experienceController;

  // Add controllers for other fields as needed

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _instructorController = TextEditingController();
    _durationController = TextEditingController();
    _startDateController = TextEditingController();
    _experienceController = TextEditingController();

    // Initialize other controllers with current values
    fetchCourseDetails();
  }

  void fetchCourseDetails() {
    FirebaseFirestore.instance
        .collection('Applications')
        .doc(widget.docId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        _nameController.text = data['courseName'];
        _priceController.text = data['coursePrice'];
        _descriptionController.text = data['courseDescription'];
        _instructorController.text = data['instructorName'];
        _durationController.text = data['courseDuration'];
        _startDateController.text = data['preferredStartDate'];
        _experienceController.text = data['previousExperience'];

        // Update other controllers with current values
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  void onUpdate() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance
          .collection('Applications')
          .doc(widget.docId)
          .update({
        'courseName': _nameController.text,
        'coursePrice': _priceController.text,
        'courseDescription': _descriptionController.text,
        'instructorName': _instructorController.text,
        'courseDuration': _durationController.text,
        'preferredStartDate': _startDateController.text,
        'previousExperience': _experienceController.text,

        // Update other fields as needed
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context); // Go back after updating
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update course: $error'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Course Price'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a course price';
                  }
                  return null;
                },
              ),
              // Add other fields and controllers as needed
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Course description'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a course description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _instructorController,
                decoration: const InputDecoration(labelText: 'instructorName'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a instructorName';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'courseDuration'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a courseDuration';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _startDateController,
                decoration:
                    const InputDecoration(labelText: 'preferredStartDate'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a preferredStartDate';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _experienceController,
                decoration:
                    const InputDecoration(labelText: 'previousExperience'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a previousExperience';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: onUpdate,
                child: const Text('Update Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
