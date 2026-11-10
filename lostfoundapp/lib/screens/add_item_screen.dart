import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final title = TextEditingController();
  final category = TextEditingController();
  final location = TextEditingController();
  final description = TextEditingController();
  final postedBy = TextEditingController();
  String status = 'Lost';

  @override
  void dispose() {
    title.dispose(); category.dispose(); location.dispose(); description.dispose(); postedBy.dispose();
    super.dispose();
  }

  Future<void> saveItem() async {
    await FirebaseFirestore.instance.collection('items').add({
      'title': title.text.trim(), 'category': category.text.trim(), 'location': location.text.trim(),
      'status': status, 'description': description.text.trim(), 'postedBy': postedBy.text.trim(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Add Item')),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650),
        child: SingleChildScrollView(padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Post a lost or found item', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 16),
            TextField(controller: category, decoration: const InputDecoration(labelText: 'Category')),
            const SizedBox(height: 16),
            TextField(controller: location, decoration: const InputDecoration(labelText: 'Location')),
            const SizedBox(height: 16),
            Row(children: [const Text('Status: '), Expanded(child: DropdownButton<String>(value: status, isExpanded: true,
              items: ['Lost', 'Found'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: (value) { if (value != null) setState(() => status = value); }))]),
            const SizedBox(height: 16),
            TextField(controller: description, maxLines: 4, decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true)),
            const SizedBox(height: 16),
            TextField(controller: postedBy, decoration: const InputDecoration(labelText: 'Posted By')),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: saveItem, icon: const Icon(Icons.save_outlined), label: const Text('Save Item')),
          ]),
        ),
      )),
    );
  }
}
