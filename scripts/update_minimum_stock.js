#!/usr/bin/env node

const admin = require('firebase-admin');

// Initialize Firebase using default credentials
const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!serviceAccountPath) {
  console.error('❌ Error: GOOGLE_APPLICATION_CREDENTIALS environment variable not set');
  process.exit(1);
}

try {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} catch (error) {
  console.error('❌ Error initializing Firebase:', error.message);
  console.log('\nTry: firebase login and then firebase use <project-id>');
  process.exit(1);
}

const db = admin.firestore();

async function updateMinimumStock() {
  try {
    console.log('🔄 Starting to update minimum_stock values...\n');
    
    const itemsRef = db.collection('items');
    const snapshot = await itemsRef.get();
    
    console.log(`📊 Found ${snapshot.docs.length} items\n`);
    
    let updatedCount = 0;
    const batch = db.batch();
    
    snapshot.forEach((doc) => {
      const data = doc.data();
      const randomMinimumStock = String(10 + Math.floor(Math.random() * 91)); // 10-100
      
      batch.update(doc.ref, {
        minimum_stock: randomMinimumStock,
      });
      
      console.log(`✓ ${data.item_name} → minimum_stock: ${randomMinimumStock}`);
      updatedCount++;
    });
    
    // Commit the batch
    await batch.commit();
    
    console.log(`\n✅ Successfully updated ${updatedCount} items with random minimum_stock values`);
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

updateMinimumStock();
