import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin
cred = credentials.Certificate('google-services.json')  # Update path if needed
firebase_admin.initialize_app(cred)

# Get Firestore client
db = firestore.client()

# Get all users
users_ref = db.collection('users')
users = users_ref.stream()

print("=" * 80)
print("CHECKING USER APPROVAL STATUS")
print("=" * 80)

for user in users:
    user_data = user.to_dict()
    uid = user.id
    email = user_data.get('email', 'N/A')
    role = user_data.get('role', 'N/A')
    is_approved = user_data.get('is_approved', None)
    admin_request = user_data.get('admin_request', None)
    
    print(f"\n📧 Email: {email}")
    print(f"   UID: {uid}")
    print(f"   Role: {role}")
    print(f"   is_approved: {is_approved} (type: {type(is_approved).__name__})")
    print(f"   admin_request: {admin_request}")
    print(f"   Can access cashier: {is_approved == True}")
    print("-" * 80)

print("\n✅ Check complete!")
