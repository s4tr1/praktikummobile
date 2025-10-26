class QuizModel {
  final int? id;
  final int courseId;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;

  QuizModel({
    this.id,
    required this.courseId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });

  factory QuizModel.fromMap(Map<String, dynamic> m) => QuizModel(
    id: m['id'] as int?,
    courseId: m['courseId'] as int,
    question: m['question'] as String,
    optionA: m['optionA'] as String,
    optionB: m['optionB'] as String,
    optionC: m['optionC'] as String,
    optionD: m['optionD'] as String,
    correctAnswer: m['correctAnswer'] as String,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'courseId': courseId,
    'question': question,
    'optionA': optionA,
    'optionB': optionB,
    'optionC': optionC,
    'optionD': optionD,
    'correctAnswer': correctAnswer,
  };
}
