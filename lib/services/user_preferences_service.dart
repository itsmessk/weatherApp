import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');
  
  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;
  
  // Check if user is logged in
  bool get isUserLoggedIn => _currentUserId != null;
  
  // Get user document reference
  DocumentReference? get _userDocRef => 
      isUserLoggedIn ? _usersCollection.doc(_currentUserId) : null;
  
  // Get user preferences collection reference
  CollectionReference? get _userPreferencesCollection => 
      isUserLoggedIn ? _userDocRef?.collection('preferences') : null;
  
  // Initialize user preferences when user signs up
  Future<void> initializeUserPreferences() async {
    if (!isUserLoggedIn) return;
    
    try {
      // Check if user document exists
      final userDoc = await _userDocRef?.get();
      
      if (userDoc == null || !userDoc.exists) {
        // Create user document with default data
        await _userDocRef?.set({
          'email': _auth.currentUser?.email,
          'displayName': _auth.currentUser?.displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        
        // Create default preferences
        await _userPreferencesCollection?.doc('general').set({
          'temperatureUnit': 'celsius',
          'windSpeedUnit': 'kmh',
          'theme': 'system',
          'defaultLocation': '',
          'notificationsEnabled': true,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        
        // Create default favorite cities collection
        await _userDocRef?.collection('favoriteCities').doc('info').set({
          'count': 0,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Update last login time
        await _userDocRef?.update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error initializing user preferences: $e');
      rethrow;
    }
  }
  
  // Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    if (!isUserLoggedIn) return null;
    
    try {
      final preferencesDoc = await _userPreferencesCollection?.doc('general').get();
      
      if (preferencesDoc == null || !preferencesDoc.exists) {
        return null;
      }
      
      return preferencesDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user preferences: $e');
      return null;
    }
  }
  
  // Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    if (!isUserLoggedIn) return;
    
    try {
      await _userPreferencesCollection?.doc('general').update({
        ...preferences,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user preferences: $e');
      rethrow;
    }
  }
  
  // Get favorite cities
  Future<List<String>> getFavoriteCities() async {
    if (!isUserLoggedIn) return [];
    
    try {
      final favoritesSnapshot = await _userDocRef?.collection('favoriteCities').get();
      
      if (favoritesSnapshot == null) return [];
      
      final List<String> favorites = [];
      
      for (var doc in favoritesSnapshot.docs) {
        if (doc.id != 'info') {
          favorites.add(doc.id);
        }
      }
      
      return favorites;
    } catch (e) {
      print('Error getting favorite cities: $e');
      return [];
    }
  }
  
  // Add city to favorites
  Future<void> addFavoriteCity(String cityName) async {
    if (!isUserLoggedIn) return;
    
    try {
      await _userDocRef?.collection('favoriteCities').doc(cityName).set({
        'addedAt': FieldValue.serverTimestamp(),
      });
      
      // Update count in info document
      final infoDoc = await _userDocRef?.collection('favoriteCities').doc('info').get();
      
      if (infoDoc != null && infoDoc.exists) {
        final currentCount = infoDoc.data()?['count'] ?? 0;
        await _userDocRef?.collection('favoriteCities').doc('info').update({
          'count': currentCount + 1,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding favorite city: $e');
      rethrow;
    }
  }
  
  // Remove city from favorites
  Future<void> removeFavoriteCity(String cityName) async {
    if (!isUserLoggedIn) return;
    
    try {
      await _userDocRef?.collection('favoriteCities').doc(cityName).delete();
      
      // Update count in info document
      final infoDoc = await _userDocRef?.collection('favoriteCities').doc('info').get();
      
      if (infoDoc != null && infoDoc.exists) {
        final currentCount = infoDoc.data()?['count'] ?? 0;
        if (currentCount > 0) {
          await _userDocRef?.collection('favoriteCities').doc('info').update({
            'count': currentCount - 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error removing favorite city: $e');
      rethrow;
    }
  }
  
  // Check if city is in favorites
  Future<bool> isCityInFavorites(String cityName) async {
    if (!isUserLoggedIn) return false;
    
    try {
      final docSnapshot = await _userDocRef?.collection('favoriteCities').doc(cityName).get();
      return docSnapshot != null && docSnapshot.exists;
    } catch (e) {
      print('Error checking if city is in favorites: $e');
      return false;
    }
  }
}
