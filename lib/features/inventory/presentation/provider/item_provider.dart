import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/item_remote_datasource.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/usecase/get_all_item.dart';
import '../../domain/usecase/get_item.dart';
import '../../domain/usecase/create_item.dart';
import '../../domain/usecase/update_item.dart';
import '../../domain/usecase/delete_item.dart';

class ItemState {
  final List<ItemEntity> items;
  final ItemEntity? selectedItem;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final Map<String, String> formErrors;
  final String? searchQuery;

  ItemState({
    this.items = const [],
    this.selectedItem,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.formErrors = const {},
    this.searchQuery,
  });

  ItemState copyWith({
    List<ItemEntity>? items,
    ItemEntity? selectedItem,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    Map<String, String>? formErrors,
    String? searchQuery,
  }) {
    return ItemState(
      items: items ?? this.items,
      selectedItem: selectedItem ?? this.selectedItem,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      formErrors: formErrors ?? this.formErrors,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ItemNotifier extends StateNotifier<ItemState> {
  final GetAllItem getAllItem;
  final GetItem getItem;
  final CreateItem createItem;
  final UpdateItem updateItem;
  final DeleteItem deleteItem;

  ItemNotifier({
    required this.getAllItem,
    required this.getItem,
    required this.createItem,
    required this.updateItem,
    required this.deleteItem,
  }) : super(ItemState());

  Future<void> fetchAllItems() async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      final items = await getAllItem();
      state = state.copyWith(items: items, isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  Future<void> searchItems(String query) async {
    state = state.copyWith(searchQuery: query);
    if (query.isEmpty) {
      await fetchAllItems();
    } else {
      final filtered = state.items.where((item) =>
        item.itemName.toLowerCase().contains(query.toLowerCase()) ||
        item.itemCode.toLowerCase().contains(query.toLowerCase())
      ).toList();
      state = state.copyWith(items: filtered);
    }
  }

  Future<void> selectItem(String uid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final item = await getItem(uid);
      state = state.copyWith(selectedItem: item, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearSelection() {
    state = state.copyWith(selectedItem: null);
  }

  Future<void> createNewItem(ItemEntity item) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    final errors = _validateItem(item);
    if (errors.isNotEmpty) {
      state = state.copyWith(isLoading: false, formErrors: errors, isSuccess: false);
      return;
    }
    try {
      await createItem(item);
      state = state.copyWith(isLoading: false, isSuccess: true, formErrors: {});
      await fetchAllItems();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  Future<void> updateExistingItem(ItemEntity item) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    final errors = _validateItem(item);
    if (errors.isNotEmpty) {
      state = state.copyWith(isLoading: false, formErrors: errors, isSuccess: false);
      return;
    }
    try {
      await updateItem(item);
      state = state.copyWith(isLoading: false, isSuccess: true, formErrors: {});
      await fetchAllItems();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  Future<void> deleteExistingItem(String uid) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await deleteItem(uid);
      state = state.copyWith(isLoading: false, isSuccess: true);
      await fetchAllItems();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  Map<String, String> _validateItem(ItemEntity item) {
    final errors = <String, String>{};
    if (item.itemName.isEmpty) errors['itemName'] = 'Item name is required';
    if (item.itemCode.isEmpty) errors['itemCode'] = 'Item code is required';
    if (item.category.isEmpty) errors['category'] = 'Category is required';
    if (item.measure.isEmpty) errors['measure'] = 'Measure is required';
    // Add more validation as needed
    return errors;
  }
}

// Example provider registration (to be used in your main.dart or feature module)
final itemProvider = StateNotifierProvider<ItemNotifier, ItemState>((ref) {
  final firestore = FirebaseFirestore.instance;
  final remoteDataSource = ItemRemoteDataSource(firestore);
  final repository = ItemRepositoryImpl(remoteDataSource);

  return ItemNotifier(
    getAllItem: GetAllItem(repository),
    getItem: GetItem(repository),
    createItem: CreateItem(repository),
    updateItem: UpdateItem(repository),
    deleteItem: DeleteItem(repository),
  );
});