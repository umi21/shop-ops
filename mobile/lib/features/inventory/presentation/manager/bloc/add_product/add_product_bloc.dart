import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/inventory/domain/usecases/add_product_usecase.dart';
import 'package:uuid/uuid.dart';
import 'add_product_event.dart';
import 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final AddProductUseCase addProductUseCase;
  final String businessId;
  final Function(Product)? onProductAdded;

  AddProductBloc({
    required this.addProductUseCase,
    this.businessId = 'default_business_id',
    this.onProductAdded,
  }) : super(const AddProductState()) {
    on<UpdateStockEvent>(_onUpdateStock);
    on<UpdatePricesEvent>(_onUpdatePrices);
    on<SubmitProductEvent>(_onSubmitProduct);
  }

  void _onUpdateStock(UpdateStockEvent event, Emitter<AddProductState> emit) {
    if (event.newStock >= 0) {
      emit(state.copyWith(stock: event.newStock));
    }
  }

  void _onUpdatePrices(UpdatePricesEvent event, Emitter<AddProductState> emit) {
    double margin = event.sellingPrice - event.costPrice;
    double percentage = 0.0;

    if (event.sellingPrice > 0) {
      percentage = (margin / event.sellingPrice) * 100;
    }

    emit(
      state.copyWith(
        costPrice: event.costPrice,
        sellingPrice: event.sellingPrice,
        marginAmount: margin,
        marginPercentage: percentage,
      ),
    );
  }

  Future<void> _onSubmitProduct(
    SubmitProductEvent event,
    Emitter<AddProductState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final product = Product(
      id: const Uuid().v4(),
      businessId: businessId,
      name: event.name,
      defaultSellingPrice: event.sellingPrice,
      stockQuantity: event.stockQuantity,
      lowStockThreshold: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await addProductUseCase(AddProductParams(product: product));

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (product) {
        onProductAdded?.call(product);
        emit(state.copyWith(isLoading: false, isSuccess: true));
      },
    );
  }
}
