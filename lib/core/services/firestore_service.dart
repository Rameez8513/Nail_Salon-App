import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get clients => _db.collection('clients');
  CollectionReference get services => _db.collection('services');
  CollectionReference get inventory => _db.collection('inventory');
  CollectionReference get appointments => _db.collection('appointments');
  CollectionReference get employees => _db.collection('employees');

  String? get _currentUserEmail => FirebaseAuth.instance.currentUser?.email;

  Stream<QuerySnapshot> clientsStream() =>
      clients.orderBy('createdAt', descending: true).snapshots();
  Stream<QuerySnapshot> servicesStream() =>
      services.orderBy('createdAt', descending: true).snapshots();
  Stream<QuerySnapshot> inventoryStream() =>
      inventory.orderBy('createdAt', descending: true).snapshots();
  Stream<QuerySnapshot> employeesStream() =>
      employees.orderBy('createdAt', descending: true).snapshots();

  Stream<QuerySnapshot> appointmentsForDateStream(String dateKey) {
    return appointments.where('dateKey', isEqualTo: dateKey).snapshots();
  }

  Stream<QuerySnapshot> appointmentsForWeekStream(
    DateTime weekStart,
    DateTime weekEnd,
  ) {
    final startKey = DateFormat('yyyy-MM-dd').format(weekStart);
    final endKey = DateFormat('yyyy-MM-dd').format(weekEnd);
    return appointments
        .where('dateKey', isGreaterThanOrEqualTo: startKey)
        .where('dateKey', isLessThanOrEqualTo: endKey)
        .snapshots();
  }

  Stream<QuerySnapshot> appointmentHistoryStream() => appointments.snapshots();

  Future<List<QueryDocumentSnapshot>> getAppointmentsForDate(
    String dateKey,
  ) async {
    final snapshot = await appointments
        .where('dateKey', isEqualTo: dateKey)
        .get();
    return snapshot.docs;
  }

  Future<DocumentSnapshot> getClient(String clientId) =>
      clients.doc(clientId).get();

  Future<void> addClient(Map<String, dynamic> data) {
    data['createdByEmail'] = _currentUserEmail;
    data['updatedByEmail'] = _currentUserEmail;
    return clients.add(data);
  }

  Future<void> addService(Map<String, dynamic> data) {
    data['createdByEmail'] = _currentUserEmail;
    data['updatedByEmail'] = _currentUserEmail;
    return services.add(data);
  }

  Future<void> addProduct(Map<String, dynamic> data) {
    data['createdByEmail'] = _currentUserEmail;
    data['updatedByEmail'] = _currentUserEmail;
    return inventory.add(data);
  }

  Future<void> addEmployee(Map<String, dynamic> data) {
    data['createdByEmail'] = _currentUserEmail;
    data['updatedByEmail'] = _currentUserEmail;
    return employees.add(data);
  }

  Future<void> addAppointment(Map<String, dynamic> data) {
    data['createdByEmail'] = _currentUserEmail;
    return appointments.add(data);
  }

  Future<void> updateAppointment(String id, Map<String, dynamic> data) {
    data['updatedByEmail'] = _currentUserEmail;
    return appointments.doc(id).update(data);
  }

  Future<void> updateClient(String id, Map<String, dynamic> data) {
    data['updatedByEmail'] = _currentUserEmail;
    return clients.doc(id).update(data);
  }

  Future<void> updateService(String id, Map<String, dynamic> data) {
    data['updatedByEmail'] = _currentUserEmail;
    return services.doc(id).update(data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) {
    data['updatedByEmail'] = _currentUserEmail;
    return inventory.doc(id).update(data);
  }

  Future<void> updateEmployee(String id, Map<String, dynamic> data) {
    data['updatedByEmail'] = _currentUserEmail;
    return employees.doc(id).update(data);
  }

  Future<void> deleteClient(String id) => clients.doc(id).delete();
  Future<void> deleteService(String id) => services.doc(id).delete();
  Future<void> deleteProduct(String id) => inventory.doc(id).delete();
  Future<void> deleteAppointment(String id) => appointments.doc(id).delete();
  Future<void> deleteEmployee(String id) => employees.doc(id).delete();
}
