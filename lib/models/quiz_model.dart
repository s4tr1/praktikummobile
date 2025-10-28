class QuizModel {
  final String id;
  final String question;
  final List<String> options;
  final int answerIndex; // 0-based index

  QuizModel({
    required this.id,
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  factory QuizModel.fromMap(Map<String, dynamic> m) {
    final opts = List<String>.from(m['options'] ?? []);
    return QuizModel(
      id: m['id'].toString(),
      question: m['question'] ?? '',
      options: opts,
      answerIndex: m['answer_index'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'options': options,
    'answer_index': answerIndex,
  };
}
