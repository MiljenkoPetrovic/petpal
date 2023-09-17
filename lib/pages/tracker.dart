import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  List<DateTime> _dateList = [];
  bool _allPetsFed = false;
  bool _allPetsWalked = false;
  List<QueryDocumentSnapshot> petDocs = []; // Declare petDocs here

  @override
  void initState() {
    super.initState();
    _dateList = generateDateList();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => _updateDatesManually(),
                child: Text("Manual Update"),
              ),
              Text("All Pets Fed:"),
              Checkbox(
                value: _allPetsFed,
                onChanged: (value) {
                  _updateAllPetsFed(value ?? false);
                },
              ),
              Text("All Pets Walked:"),
              Checkbox(
                value: _allPetsWalked,
                onChanged: (value) {
                  _updateAllPetsWalked(value ?? false);
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buildDateContainers(petDocs),
          ),
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
    return _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('pets')
        .snapshots();
  }

  List<Widget> buildDateContainers(List<QueryDocumentSnapshot>? petDocs) {
    final dates = generateDateList();
    final dateWidgets = <Widget>[];

    if (petDocs != null) {
      for (final date in dates) {
        final formattedDate = DateFormat('MMM dd').format(date);
        final petsOnDate = petDocs.where((doc) {
          final petData = doc.data() as Map<String, dynamic>;
          final petFed = petData['fed'] as bool;
          final petWalked = petData['walked'] as bool;
          final petDate = petData['date'] as Timestamp?;

          // Check if petDate is not null before accessing it
          if (petDate != null) {
            final petDateTime = petDate.toDate();
            return petDateTime.year == date.year &&
                petDateTime.month == date.month &&
                petDateTime.day == date.day &&
                petFed &&
                petWalked;
          }

          // Handle the case where petDate is null
          return false;
        });

        final isAllPetsFedAndWalked = petsOnDate.length == petDocs.length;

        dateWidgets.add(
          Container(
            width: 80,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isAllPetsFedAndWalked ? Colors.green : Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              formattedDate,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    }

    return dateWidgets;
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

  void _updateDatesManually() {
    setState(() {
      _dateList = generateDateList();
    });
  }

  void _updateAllPetsFed(bool fed) {
    setState(() {
      _allPetsFed = fed;
    });
  }

  void _updateAllPetsWalked(bool walked) {
    setState(() {
      _allPetsWalked = walked;
    });
  }

  List<DateTime> generateDateList() {
    final today = DateTime.now();
    final dates = <DateTime>[];

    for (int i = -2; i <= 2; i++) {
      final date = today.add(Duration(days: i));
      dates.add(date);
    }

    return dates;
  }

  void signUserOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginOrRegisterPage(),
      ),
    );
  }
}

void main() {
  final FirebaseStorage storage = FirebaseStorage.instance;
  runApp(MaterialApp(
    home: TrackerPage(storage: storage),
  ));
}
