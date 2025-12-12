#!/usr/bin/env python3
"""
Update minimum_stock values in Firebase Firestore using Firebase Admin SDK
Uses service account key for authentication
"""

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import random
import os
import sys
from pathlib import Path

def find_service_account_key():
    """Find the service account key file"""
    workspace_path = Path(__file__).parent.parent
    
    possible_files = [
        workspace_path / 'serviceAccountKey.json',
        workspace_path / 'vreetory-app-firebase-adminsdk-fbsvc-3d0003af26.json',
    ]
    
    for file in possible_files:
        if file.exists():
            return str(file)
    
    return None

def main():
    print("🔄 Starting minimum_stock batch update...\n")
    
    # Find service account key
    key_file = find_service_account_key()
    if not key_file:
        print("❌ Error: Cannot find Firebase service account key file")
        print("   Looking for: serviceAccountKey.json or vreetory-app-firebase-adminsdk-*.json")
        sys.exit(1)
    
    print(f"🔑 Using service account: {key_file}\n")
    
    # Initialize Firebase Admin SDK
    try:
        cred = credentials.Certificate(key_file)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("✓ Firebase initialized successfully\n")
    except Exception as e:
        print(f"❌ Error initializing Firebase: {e}")
        sys.exit(1)
    
    # Get all items
    try:
        print("📊 Fetching items from Firestore...")
        items_ref = db.collection('items')
        docs = items_ref.stream()
        
        items_list = list(docs)
        print(f"✓ Found {len(items_list)} items\n")
        
        if not items_list:
            print("⚠️  No items found in Firestore")
            return
        
        # Update each item
        print(f"📝 Updating items with random minimum_stock values (10-100)\n")
        
        updated_count = 0
        for doc in items_list:
            try:
                data = doc.to_dict()
                item_name = data.get('item_name', 'Unknown')
                
                # Generate random minimum stock between 10 and 100
                random_minimum_stock = str(10 + random.randint(0, 90))
                
                # Update the document
                doc.reference.update({
                    'minimum_stock': random_minimum_stock
                })
                
                print(f"✓ {item_name} → minimum_stock: {random_minimum_stock}")
                updated_count += 1
                
            except Exception as e:
                item_name = data.get('item_name', 'Unknown')
                print(f"✗ Error updating {item_name}: {e}")
                continue
        
        print(f"\n✅ Successfully updated {updated_count}/{len(items_list)} items")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
