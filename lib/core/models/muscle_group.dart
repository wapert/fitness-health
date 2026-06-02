enum MuscleGroup {
  chest('胸', '胸大肌'),
  back('背', '背闊肌・豎脊肌'),
  glutes('臀', '臀大肌・臀中肌'),
  quads('大腿前側', '股四頭肌'),
  hamstrings('大腿後側', '腿後肌群'),
  calves('小腿', '腓腸肌・比目魚肌'),
  biceps('手臂二頭', '肱二頭肌'),
  triceps('手臂三頭', '肱三頭肌'),
  shoulders('肩', '三角肌'),
  core('核心', '腹直肌・腹斜肌');

  const MuscleGroup(this.label, this.description);
  final String label;
  final String description;
}
