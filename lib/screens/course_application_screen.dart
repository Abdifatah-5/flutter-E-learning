import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseApplicationScreen extends StatefulWidget {
  const CourseApplicationScreen({Key? key}) : super(key: key);

  @override
  _CourseApplicationScreenState createState() =>
      _CourseApplicationScreenState();
}

class _CourseApplicationScreenState extends State<CourseApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _courseName = '';
  String _coursePrice = '';
  String _courseDescription = '';
  String _instructorName = '';
  String _courseDuration = '';
  String _preferredStartDate = '';
  String _previousExperience = '';

  late CollectionReference applicationsCollection;

  @override
  void initState() {
    super.initState();
    applicationsCollection =
        FirebaseFirestore.instance.collection('Applications');
  }

  Future<void> applyForCourse(
    String courseId,
    String courseName,
    String coursePrice,
    String courseDescription,
    String instructorName,
    String courseDuration,
    String preferredStartDate,
    String previousExperience,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await applicationsCollection.add({
        'userId': user.uid,
        'courseId': courseId,
        'courseName': courseName,
        'coursePrice': coursePrice,
        'courseDescription': courseDescription,
        'instructorName': instructorName,
        'courseDuration': courseDuration,
        'preferredStartDate': preferredStartDate,
        'previousExperience': previousExperience,
        'timestamp': Timestamp.now(),
      });
    }
  }

  Future<void> deleteCourseApplication(String documentId) async {
    await applicationsCollection.doc(documentId).delete();
  }

  Future<void> updateCourseApplication(
    String documentId,
    String courseName,
    String coursePrice,
    String courseDescription,
    String instructorName,
    String courseDuration,
    String preferredStartDate,
    String previousExperience,
  ) async {
    await applicationsCollection.doc(documentId).update({
      'courseName': courseName,
      'coursePrice': coursePrice,
      'courseDescription': courseDescription,
      'instructorName': instructorName,
      'courseDuration': courseDuration,
      'preferredStartDate': preferredStartDate,
      'previousExperience': previousExperience,
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String courseId = ''; // Replace with actual course ID retrieval logic
      applyForCourse(
        courseId,
        _courseName,
        _coursePrice,
        _courseDescription,
        _instructorName,
        _courseDuration,
        _preferredStartDate,
        _previousExperience,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application submitted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Application'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _courseName = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Course Price',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course price';
                  }
                  return null;
                },
                onSaved: (value) {
                  _coursePrice = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Course Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _courseDescription = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Instructor Name',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  _instructorName = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Course Duration',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  _courseDuration = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Preferred Start Date',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  _preferredStartDate = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Previous Experience',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) {
                  _previousExperience = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Apply'),
              ),
              SizedBox(height: 20),
              Text(
                'Your Applied Courses:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: applicationsCollection
                      .where('userId',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No courses applied yet.'));
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = snapshot.data!.docs[index];
                        return CourseCard(
                          name: doc['courseName'],
                          price: doc['coursePrice'],
                          description: doc['courseDescription'],
                          instructor: doc['instructorName'],
                          duration: doc['courseDuration'],
                          startDate: doc['preferredStartDate'],
                          experience: doc['previousExperience'],
                          onDelete: () {
                            deleteCourseApplication(doc.id);
                          },
                          onUpdate: () {
                            // Implement update functionality as needed
                            // You can navigate to another screen to update the course details
                            // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateCourseScreen(doc: doc)));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  CourseCard({
    required this.name,
    required this.price,
    required this.description,
    required this.instructor,
    required this.duration,
    required this.startDate,
    required this.experience,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: onUpdate,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text('Price: \$$price'),
            SizedBox(height: 8.0),
            Text(description),
            SizedBox(height: 8.0),
            Text('Instructor: $instructor'),
            SizedBox(height: 8.0),
            Text('Duration: $duration'),
            SizedBox(height: 8.0),
            Text('Start Date: $startDate'),
            SizedBox(height: 8.0),
            Text('Experience: $experience'),
          ],
        ),
      ),
    );
  }
}
