import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/features/history/data/history_local_datasource.dart';
import 'package:skinsense/features/history/domain/entities/history_record.dart';

class HistoryState extends Equatable {
  const HistoryState({this.records = const [], this.loading = true});

  final List<HistoryRecord> records;
  final bool loading;

  @override
  List<Object?> get props => [records, loading];
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._dataSource) : super(const HistoryState());

  final HistoryLocalDataSource _dataSource;

  Future<void> load() async {
    try {
      emit(HistoryState(records: await _dataSource.getAll(), loading: false));
    } catch (_) {
      emit(const HistoryState(loading: false));
    }
  }

  Future<void> add(HistoryRecord record) async {
    await _dataSource.insert(record);
    await load();
  }

  Future<void> remove(String id) async {
    await _dataSource.delete(id);
    await load();
  }

  Future<void> clear() async {
    await _dataSource.clear();
    await load();
  }
}
