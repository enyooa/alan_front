import 'package:cash_control/bloc/services/unit_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/events/unit_event.dart';
import 'package:cash_control/bloc/states/unit_state.dart';

class UnitBloc extends Bloc<UnitEvent, UnitState> {
  final UnitService unitService;

  UnitBloc({required this.unitService}) : super(UnitInitial()) {
    on<CreateUnitEvent>(_onCreateUnit);
  }

  Future<void> _onCreateUnit(CreateUnitEvent event, Emitter<UnitState> emit) async {
    emit(UnitLoading());
    try {
      final response = await unitService.createUnit(event.name);
      if (response.statusCode == 201) {
        emit(UnitCreated());
      } else {
        emit(UnitError('Не удалось создать ед измерения'));
      }
    } catch (e) {
      emit(UnitError(e.toString()));
    }
  }
}
