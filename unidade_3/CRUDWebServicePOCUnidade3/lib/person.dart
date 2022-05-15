import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Person extends StatefulWidget {
  const Person({Key? key}) : super(key: key);

  @override
  _PersonState createState() => _PersonState();
}

class _PersonState extends State<Person> {
  final TextEditingController _nameController = TextEditingController();
  bool _activeController = false;
  final TextEditingController _surnameController = TextEditingController();

  final CollectionReference _people =
  FirebaseFirestore.instance.collection('person');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _surnameController.text = documentSnapshot['surname'];
      _activeController = documentSnapshot['active'];

    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: _surnameController,
                  decoration: const InputDecoration(
                    labelText: 'Sobrenome',
                  ),
                ),
            StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Center(
              child: CheckboxListTile(
                title: const Text('Ativo'),
                value: _activeController,
                onChanged: (value) {
                  setState(() {
                    _activeController = value!;
                  });
                },
              ),
            );
          }),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? name = _nameController.text;
                    final String? surname = _surnameController.text;
                    final bool active = _activeController;
                    if (name != null
                        && surname != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _people.add({"name": name, "surname": surname, "active": active});
                      }

                      if (action == 'update') {
                        // Update the product
                        await _people
                            .doc(documentSnapshot!.id)
                            .update({"name": name, "surname": surname, "active": active});
                      }

                      // Clear the text fields
                      _nameController.text = '';
                      _activeController = true;
                      _surnameController.text = '';
                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _deleteProduct(String productId) async {
    await _people.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pessoa deletada com sucesso')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebService'),
      ),
      body: StreamBuilder(
        stream: _people.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(documentSnapshot['surname']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteProduct(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}