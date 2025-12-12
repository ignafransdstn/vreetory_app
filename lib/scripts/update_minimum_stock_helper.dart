import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

// SIMPLE SCRIPT TO UPDATE MINIMUM_STOCK VIA FIRESTORE
// Run this by navigating to this page from admin menu temporarily

void updateMinimumStockForAllItems() async {
  final firestore = FirebaseFirestore.instance;
  final random = Random();
  
  try {
    print('🔄 Starting to update minimum_stock values...');
    
    final querySnapshot = await firestore.collection('items').get();
    
    print('📊 Found ${querySnapshot.docs.length} items');
    
    int updatedCount = 0;
    
    for (var doc in querySnapshot.docs) {
      try {
        final data = doc.data();
        
        // Generate random minimum stock between 10 and 100
        final randomMinimumStock = (10 + random.nextInt(91)).toString();
        
        // Update the document
        await doc.reference.update({
          'minimum_stock': randomMinimumStock,
        });
        
        print('✓ Updated ${data['item_name']} with minimum_stock: $randomMinimumStock');
        updatedCount++;
      } catch (e) {
        print('✗ Error updating item: $e');
      }
    }
    
    print('\n✅ Successfully updated $updatedCount items with random minimum_stock values');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
