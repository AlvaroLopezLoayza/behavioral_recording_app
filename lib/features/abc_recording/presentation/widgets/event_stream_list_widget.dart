import 'package:flutter/material.dart';
import '../../domain/entities/abc_record.dart';

class EventStreamListWidget extends StatelessWidget {
  final List<AbcRecord> records;
  final Function(AbcRecord) onTap;
  final Function(AbcRecord) onDelete;

  const EventStreamListWidget({
    super.key,
    required this.records,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'La sesión comenzará al primer registro',
              style: TextStyle(color: Colors.grey.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: records.length,
      itemBuilder: (context, index) {
        // Reverse order usually preferred for streams (newest top), 
        // but let's assume the parent passes pre-sorted list.
        final record = records[index];
        final bool isComplete = record.antecedent['description'] != null && 
                                record.consequence['description'] != null;

        return Dismissible(
          key: Key(record.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onDelete(record),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () => onTap(record),
              leading: CircleAvatar(
                backgroundColor: isComplete ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                child: Icon(
                  isComplete ? Icons.check : Icons.edit_note,
                  size: 20,
                  color: isComplete ? Colors.green : Colors.orange,
                ),
              ),
              title: Text(
                _formatTime(record.timestamp),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isComplete ? 'Registro completo' : 'Toca para agregar detalles',
                style: TextStyle(
                  color: isComplete ? Colors.grey : Colors.orange,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
