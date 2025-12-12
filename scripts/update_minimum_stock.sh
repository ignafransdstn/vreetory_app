#!/bin/bash
# Update minimum_stock values in Firestore using REST API
# No authentication needed if using Firebase Emulator, or requires service account for production

PROJECT_ID="vreetory-app"
COLLECTION="items"

# Get items using firebase CLI
echo "🔄 Fetching all items from Firestore..."

# This will use your logged-in Firebase CLI credentials
firebase firestore:inspect ${COLLECTION} --project=${PROJECT_ID} 2>/dev/null | head -20

echo ""
echo "📝 To update minimum_stock values, run this command in Firebase Console:"
echo "   1. Go to https://console.firebase.google.com/firestore/data/${COLLECTION}?project=${PROJECT_ID}"
echo "   2. Or use the Node.js script: node scripts/update_minimum_stock.js"
echo ""
