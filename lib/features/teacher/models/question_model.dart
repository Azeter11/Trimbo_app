// question_model.dart
// Model data untuk soal pilihan ganda yang dibuat guru.

class QuestionModel {
  final String id;           // ID dokumen Firestore
  final String assignmentId; // ID tugas yang memiliki soal ini
  final int orderNumber;     // Nomor urut soal (1, 2, 3, ...)
  final String questionText; // Teks pertanyaan
  final String optionA;      // Pilihan A
  final String optionB;      // Pilihan B
  final String optionC;      // Pilihan C
  final String optionD;      // Pilihan D
  final String correctAnswer; // Jawaban benar: 'A', 'B', 'C', atau 'D'
  final String? explanation;  // Penjelasan jawaban (opsional, untuk pembahasan)

  const QuestionModel({
    required this.id,
    required this.assignmentId,
    required this.orderNumber,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.explanation,
  });

  /// Ambil teks pilihan berdasarkan huruf ('A', 'B', 'C', 'D')
  String getOptionText(String option) {
    switch (option.toUpperCase()) {
      case 'A': return optionA;
      case 'B': return optionB;
      case 'C': return optionC;
      case 'D': return optionD;
      default: return '';
    }
  }

  /// Cek apakah jawaban yang diberikan benar
  bool isCorrect(String answer) => answer.toUpperCase() == correctAnswer.toUpperCase();

  factory QuestionModel.fromMap(Map<String, dynamic> map, String id) {
    return QuestionModel(
      id: id,
      assignmentId: map['assignmentId'] ?? '',
      orderNumber: map['orderNumber'] ?? 1,
      questionText: map['questionText'] ?? '',
      optionA: map['optionA'] ?? '',
      optionB: map['optionB'] ?? '',
      optionC: map['optionC'] ?? '',
      optionD: map['optionD'] ?? '',
      correctAnswer: map['correctAnswer'] ?? 'A',
      explanation: map['explanation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'orderNumber': orderNumber,
      'questionText': questionText,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }

  QuestionModel copyWith({
    int? orderNumber,
    String? questionText,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctAnswer,
    String? explanation,
  }) {
    return QuestionModel(
      id: id,
      assignmentId: assignmentId,
      orderNumber: orderNumber ?? this.orderNumber,
      questionText: questionText ?? this.questionText,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
    );
  }
}
