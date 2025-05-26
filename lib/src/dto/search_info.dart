class SearchInfo {
  SearchInfo({
    required int id,
    required int chatId,
    required String nummer,
    required DateTime examDate,
    required DateTime birthDate,
  })  : _id = id,
        _chatId = chatId,
        _nummer = nummer,
        _examDate = examDate,
        _birthDate = birthDate;

  final int _id;
  final int _chatId;
  final String _nummer;
  final DateTime _examDate;
  final DateTime _birthDate;

  int get id => _id;
  int get chatId => _chatId;
  String get nummer => _nummer;
  DateTime get examDate => _examDate;
  DateTime get birthDate => _birthDate;
}
