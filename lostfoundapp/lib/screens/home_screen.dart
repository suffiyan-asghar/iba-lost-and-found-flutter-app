import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String search = '';
  String status = 'All';
  final itemsStream = FirebaseFirestore.instance.collection('items').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Lost & Found')),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Help belongings find their way home.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(decoration: const InputDecoration(labelText: 'Search by title', prefixIcon: Icon(Icons.search)),
              onChanged: (value) => setState(() => search = value.trim().toLowerCase())),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Status: '),
              Expanded(child: DropdownButton<String>(value: status, isExpanded: true,
                items: ['All', 'Lost', 'Found', 'Claimed'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                onChanged: (value) { if (value != null) setState(() => status = value); })),
              const SizedBox(width: 16),
              ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const AddItemScreen())), icon: const Icon(Icons.add), label: const Text('Add Item')),
            ]),
            const SizedBox(height: 12),
            Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: itemsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final items = snapshot.data!.docs.where((doc) {
                  final item = doc.data();
                  return (item['title'] ?? '').toString().toLowerCase().contains(search) && (status == 'All' || item['status'] == status);
                }).toList();
                if (items.isEmpty) return const Center(child: Text('No items found. Try another search or add an item.'));
                return ListView.builder(itemCount: items.length, itemBuilder: (context, index) {
                  final doc = items[index];
                  final item = doc.data();
                  final value = (item['status'] ?? 'Unknown').toString();
                  final color = value == 'Lost' ? Colors.red.shade700 : value == 'Found' ? Colors.green.shade700 : Colors.blueGrey;
                  return Card(color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(contentPadding: const EdgeInsets.all(16),
                      title: Text((item['title'] ?? 'Untitled item').toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SizedBox(height: 6), Text('Category: ${item['category'] ?? ''}'), Text('Location: ${item['location'] ?? ''}'),
                        const SizedBox(height: 6), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      ]),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ItemDetailScreen(itemId: doc.id)))));
                });
              },
            )),
          ],
        )),
      )),
    );
  }
}
