import 'package:alan/bloc/blocs/packer_page_blocs/events/couriers_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/repo/courier_repo.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/couriers_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class CourierBloc extends Bloc<CourierEvent, CourierState> {
  final CourierRepository repository;

  CourierBloc({required this.repository}) : super(CourierInitial()) {
    on<FetchCouriersEvent>(_onFetchCouriers);
  }

  Future<void> _onFetchCouriers(FetchCouriersEvent event, Emitter<CourierState> emit) async {
    emit(CourierLoading());
    try {
      final couriers = await repository.fetchCouriers();
      emit(CourierLoaded(couriers));
    } catch (e) {
      emit(CourierError('Failed to load couriers: $e'));
    }
  }
}
