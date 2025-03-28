import 'package:alan/bloc/blocs/packer_page_blocs/events/all_instances_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/repo/all_instances_repository.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/all_instances_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllInstancesBloc extends Bloc<AllInstancesEvent, AllInstancesState> {
  final AllInstancesRepository repository;

  AllInstancesBloc({required this.repository}) : super(AllInstancesInitial()) {
    on<FetchAllInstancesEvent>(_onFetchAllInstances);
  }

  Future<void> _onFetchAllInstances(
    FetchAllInstancesEvent event,
    Emitter<AllInstancesState> emit,
  ) async {
    emit(AllInstancesLoading());
    try {
      final data = await repository.fetchAllInstances();
      // data => { "users": [...], "unit_measurements": [...], "couriers": [...] }
      emit(AllInstancesLoaded(data));
    } catch (e) {
      emit(AllInstancesError('Failed to load instances: $e'));
    }
  }
}
