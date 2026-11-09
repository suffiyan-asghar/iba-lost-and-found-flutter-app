import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.itemId});
  final String itemId;
  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late final itemRef = FirebaseFirestore.instance.collection('items').doc(widget.itemId);
  late final itemStream = itemRef.snapshots();

  Future<void> claimItem() async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(itemRef);
      if (!snapshot.exists || snapshot.data()?['status'] == 'Claimed') return;
      transaction.update(itemRef, {'status': 'Claimed'});
    });
  }

  Future<void> deleteItem() async {
    await itemRef.delete();
    if (mounted) Navigator.pop(context);
  }

  Widget detailField(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 17)),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Item Details')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(stream: itemStream, builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (!snapshot.data!.exists) return const SizedBox.shrink();
        final item = snapshot.data!.data()!;
        final status = (item['status'] ?? 'Unknown').toString();
        final color = status == 'Lost' ? Colors.red.shade700 : status == 'Found' ? Colors.green.shade700 : Colors.blueGrey;
        return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Card(color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text((item['title'] ?? 'Untitled item').toString(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12), Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(height: 32),
              detailField('Category', (item['category'] ?? '').toString()),
              detailField('Location', (item['location'] ?? '').toString()),
              detailField('Description', (item['description'] ?? '').toString()),
              detailField('Posted By', (item['postedBy'] ?? '').toString()),
              ElevatedButton.icon(onPressed: status == 'Claimed' ? null : claimItem, icon: const Icon(Icons.check_circle_outline),
                label: Text(status == 'Claimed' ? 'Already Claimed' : 'Mark as Claimed')),
              const SizedBox(height: 12),
              OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                onPressed: deleteItem, icon: const Icon(Icons.delete_outline), label: const Text('Delete Item')),
            ])),
          )),
        ));
      }),
    );
  }
}
