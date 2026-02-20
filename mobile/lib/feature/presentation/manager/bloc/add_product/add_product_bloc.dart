import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_product_event.dart';
import 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  AddProductBloc() : super(const AddProductState()) {
    
    // Handle stock change
    on<UpdateStockEvent>((event, emit) {
      if (event.newStock >= 0) {
        emit(state.copyWith(stock: event.newStock));
      }
    });

    // Handle margin calculation
    on<UpdatePricesEvent>((event, emit) {
      double margin = event.sellingPrice - event.costPrice;
      double percentage = 0.0;
      
      if (event.sellingPrice > 0) {
        percentage = (margin / event.sellingPrice) * 100;
      }

      emit(state.copyWith(
        costPrice: event.costPrice,
        sellingPrice: event.sellingPrice,
        marginAmount: margin,
        marginPercentage: percentage,
      ));
    });
  }
}