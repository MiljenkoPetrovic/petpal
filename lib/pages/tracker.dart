import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petpal/pages/login_or_register.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class TrackerPage extends StatefulWidget {
  final FirebaseStorage storage;
  const TrackerPage({Key? key, required this.storage}) : super(key: key);
  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final TextEditingController _petNameController = TextEditingController();
  String? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> petDocs = [];
  bool allPetsFedAndWalked = false; // Moved the variable here

  @override
  void initState() {
    super.initState();
    _loadPetData(); // Load data when the page is initialized
  }

  @override
  void dispose() {
    _petNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 400,
            child: StreamBuilder<QuerySnapshot>(
              stream: _getPetData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                petDocs = snapshot.data!.docs; // Assign the value here

                final petWidgets =
                    petDocs.map((petDoc) => _buildPetWidget(petDoc)).toList();
                return ListView(
                  children: petWidgets,
                );
              },
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPetDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildPetWidget(QueryDocumentSnapshot<Object?> petDoc) {
    final petData = petDoc.data() as Map<String, dynamic>;
    final petName = petData['name'] as String;
    final petImageUrl = petData['imageUrl'] as String;
    final petFed = petData['fed'] as bool;
    final petWalked = petData['walked'] as bool;

    void _deletePet() {
      final user = _auth.currentUser;
      if (user != null) {
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(petDoc.id)
            .delete()
            .then((_) {
          print("Pet deleted successfully.");
        }).catchError((error) {
          print("Error deleting pet: $error");
        });
      }
    }

    return ListTile(
      leading: Image.network(petImageUrl),
      title: Text(petName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Fed:"),
              Checkbox(
                value: petFed,
                onChanged: (value) {
                  _updatePetFed(petDoc.id, value ?? false);
                },
              ),
            ],
          ),
          Row(
            children: [
              Text("Walked:"),
              Checkbox(
                value: petWalked,
                onChanged: (value) {
                  _updatePetWalked(petDoc.id, value ?? false);
                },
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Delete Pet"),
                content: Text("Are you sure you want to delete this pet?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _deletePet();
                      Navigator.of(context).pop();
                    },
                    child: Text("Delete"),
                  ),
                ],
              );
            },
          );
        },
      ),
      onTap: () => _showUpdatePetDialog(context, petDoc.id, petData),
    );
  }

  void _showAddPetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add a Pet"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _petNameController,
                  decoration: InputDecoration(labelText: "Pet Name"),
                ),
                ElevatedButton(
                  onPressed: () => _takePicture(context),
                  child: Text("Take Picture"),
                ),
                _selectedImage != null
                    ? Image.file(
                        File(_selectedImage!),
                        height: 100,
                      )
                    : SizedBox(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _addPet();
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showUpdatePetDialog(
      BuildContext context, String petId, Map<String, dynamic> petData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController fedController =
            TextEditingController(text: petData['fed'].toString());
        final TextEditingController walkedController =
            TextEditingController(text: petData['walked'].toString());

        return AlertDialog(
          title: Text("Update Pet Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Pet Name: ${petData['name']}"),
              Row(
                children: [
                  Text("Fed:"),
                  Checkbox(
                    value: petData['fed'],
                    onChanged: (value) {
                      fedController.text = value.toString();
                      _updatePetFed(petId, value!);
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Walked:"),
                  Checkbox(
                    value: petData['walked'],
                    onChanged: (value) {
                      walkedController.text = value.toString();
                      _updatePetWalked(petId, value!);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _updatePet(petId, fedController.text, walkedController.text);
                Navigator.of(context).pop();
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _takePicture(BuildContext context) async {
    final imagePickerResponse = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (imagePickerResponse != null) {
      setState(() {
        _selectedImage = imagePickerResponse.path;
      });
    }
  }

  Stream<QuerySnapshot> _getPetData() {
    final user = _auth.currentUser;
    final stream = _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('pets')
        .snapshots();

    return stream;
  }

  Future<void> _addPet() async {
    final user = _auth.currentUser;
    final petData = {
      'name': _petNameController.text,
      'imageUrl': '',
      'fed': false,
      'walked': false,
    };

    try {
      if (_selectedImage != null) {
        final File imageFile = File(_selectedImage!);
        final String fileName = path.basename(imageFile.path);
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('pet_images')
            .child(user!.uid)
            .child(fileName);
        final UploadTask uploadTask = storageRef.putFile(imageFile);

        await uploadTask.whenComplete(() {});

        if (uploadTask.snapshot.state == TaskState.success) {
          final imageUrl = await storageRef.getDownloadURL();
          petData['imageUrl'] = imageUrl;
        } else {
          print("Image upload failed.");
        }
      }

      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('pets')
          .add(petData);

      print("Pet added successfully.");
    } catch (e) {
      print("Error adding pet: $e");
    }
  }

  Future<void> _updatePet(String petId, String fed, String walked) async {
    final user = _auth.currentUser;

    try {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('pets')
          .doc(petId)
          .update({
        'fed': fed.toLowerCase() == 'true',
        'walked': walked.toLowerCase() == 'true',
      });
      print("Pet data updated successfully.");
    } catch (e) {
      print("Error updating pet data: $e");
    }
  }

  Future<void> _updatePetFed(String petId, bool fed) async {
    final user = _auth.currentUser;

    try {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('pets')
          .doc(petId)
          .update({'fed': fed});
      print("Pet fed status updated successfully.");
    } catch (e) {
      print("Error updating pet fed status: $e");
    }
  }

  Future<void> _updatePetWalked(String petId, bool walked) async {
    final user = _auth.currentUser;

    try {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('pets')
          .doc(petId)
          .update({'walked': walked});
      print("Pet walked status updated successfully.");
    } catch (e) {
      print("Error updating pet walked status: $e");
    }
  }

  void signUserOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginOrRegisterPage(),
      ),
    );
  }

  Future<void> _loadPetData() async {
    try {
      final snapshot = await _getPetData().first;
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          petDocs = snapshot.docs;
        });

        // Print the data from loaded documents
        for (final doc in snapshot.docs) {
          final petData = doc.data() as Map<String, dynamic>;
          print('Pet Name: ${petData['name']}');
          print('Image URL: ${petData['imageUrl']}');
          print('Fed: ${petData['fed']}');
          print('Walked: ${petData['walked']}');
          print('---'); // Separate each pet's data
        }
      } else {
        print('No data available in Firestore');
      }
    } catch (e) {
      print('Error loading data from Firestore: $e');
    }
  }
}
