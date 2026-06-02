import '../../../core/models/exercise.dart';
import '../../../core/models/muscle_group.dart';

const List<Exercise> stretchingExercises = [
  // CHEST 胸
  Exercise(
    id: 'chest_doorway',
    name: 'Doorway Chest Stretch',
    nameChinese: '門框胸肌伸展',
    type: ExerciseType.stretch,
    primaryMuscle: MuscleGroup.chest,
    equipment: Equipment.bodyweight,
    videoUrl: 'https://www.youtube.com/watch?v=tBqCGwMdmMw',
    instructions: ['手扶門框，手臂呈 90°', '身體微向前傾', '感受胸肌延伸', '保持呼吸放鬆'],
    holdSeconds: 30,
    sets: 3,
  ),
  Exercise(
    id: 'pec_minor_stretch',
    name: 'Pec Minor / Upper Chest Stretch',
    nameChinese: '胸小肌伸展',
    type: ExerciseType.stretch,
    primaryMuscle: MuscleGroup.chest,
    equipment: Equipment.bodyweight,
    instructions: ['手臂舉過頭後扶牆', '身體向前旋轉', '感受前胸及肩前延伸'],
    holdSeconds: 30,
    sets: 2,
  ),

  // BACK 背
  Exercise(
    id: 'cat_cow',
    name: 'Cat-Cow Stretch',
    nameChinese: '貓牛式',
    type: ExerciseType.stretch,
    primaryMuscle: MuscleGroup.back,
    equipment: Equipment.bodyweight,
    videoUrl: 'https://www.youtube.com/watch?v=kqnua4rHVVA',
    instructions: ['四足跪姿', '吸氣：腰下沉背抬起（牛式）', '呼氣：腰拱起低頭（貓式）', '交替進行'],
    tips: ['動作跟隨呼吸節奏，不要急'],
    holdSeconds: 0,
    sets: 10, // 10 reps
    reps: '10 次呼吸',
  ),
  Exercise(
    id: 'childs_pose',
    name: "Child's Pose",
    nameChinese: '嬰兒式',
    type: ExerciseType.stretch,
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [MuscleGroup.glutes],
    equipment: Equipment.bodyweight,
    instructions: ['跪坐後身體往前趴', '手臂向前延伸', '額頭貼地', '感受背部及肩膀放鬆'],
    holdSeconds: 60,
    sets: 2,
  ),

  // GLUTES 臀
  Exercise(
    id: 'pigeon_pose',
    name: 'Pigeon Pose',
    nameChinese: '鴿式（臀部伸展）',
    type: ExerciseType.stretch,
    primaryMuscle: MuscleGroup.glutes,
    equipment: Equipment.bodyweight,
    videoUrl: 'https://www.youtube.com/watch?v=GSRpHdKDkUE',
    instructions: ['前腳彎曲橫置', '後腳伸直', '身體向前倒下', '感受臀部深層伸展'],
    tips: ['臀部緊繃者可在前腳下方墊瑜伽磚'],
    holdSeconds: 60,
    sets: 2,
  ),
  Exercise(
    id: 'figure4_stretch',
    name: 'Figure-4 Glute Stretch',
    nameChinese: '4 字腿臀部伸展',
    type: ExerciseType.stretch,
    primaryMuscle: MuscleGroup.glutes,
    equipment: Equipment.bodyweight,
    instructions: ['仰躺', '一腳腳踝跨放於另腳膝上', '抱起下方腿靠近胸口', '感受外臀伸展'],
    holdSeconds: 45,
    sets: 2,
  ),

  // QUADS 大腿前側
  Exercise(
    id: 'standing_quad_stretch',
    name: 'Standing Quad Stretch',
    nameChinese: '站姿股四頭肌伸展',
    type: ExerciseType.stretch,
    primaryMuscle: MuscleGroup.quads,
    equipment: Equipment.bodyweight,
    instructions: ['單腳站立', '另腳腳踝向後抓住', '膝蓋向後靠攏', '感受大腿前側拉伸'],
    holdSeconds: 30,
    sets: 2,
  ),

  // HAMSTRINGS 大腿後側
  Exercise(
    id: 'seated_hamstring',
    name: 'Seated Hamstring Stretch',
    nameChinese: '坐姿腿後肌伸展',
    type: ExerciseType.stretch,
    primaryMuscle: MuscleGroup.hamstrings,
    equipment: Equipment.bodyweight,
    instructions: ['坐地腳伸直', '上身向前傾保持背直', '雙手順著腿往腳踝延伸', '感受大腿後側拉伸'],
    holdSeconds: 45,
    sets: 2,
  ),

  // CALVES 小腿
  Exercise(
    id: 'wall_calf_stretch',
    name: 'Wall Calf Stretch',
    nameChinese: '扶牆小腿伸展',
    type: ExerciseType.stretch,
    primaryMuscle: MuscleGroup.calves,
    equipment: Equipment.bodyweight,
    instructions: ['面對牆壁', '一腳向後踩穩', '腳跟貼地向前傾', '感受小腿後側延伸'],
    tips: ['膝蓋微彎可伸展比目魚肌；膝蓋伸直伸展腓腸肌'],
    holdSeconds: 30,
    sets: 2,
  ),

  // ARMS 手臂
  Exercise(
    id: 'bicep_wall_stretch',
    name: 'Wall Bicep Stretch',
    nameChinese: '扶牆二頭肌伸展',
    type: ExerciseType.stretch,
    primaryMuscle: MuscleGroup.biceps,
    equipment: Equipment.bodyweight,
    instructions: ['側身扶牆，手臂向後', '拇指朝下', '身體緩慢向前旋轉', '感受手臂前側拉伸'],
    holdSeconds: 30,
    sets: 2,
  ),
  Exercise(
    id: 'tricep_overhead',
    name: 'Overhead Tricep Stretch',
    nameChinese: '過頭三頭肌伸展',
    type: ExerciseType.stretch,
    primaryMuscle: MuscleGroup.triceps,
    equipment: Equipment.bodyweight,
    instructions: ['一手舉過頭後彎肘', '另一手輕壓肘向後', '感受手臂後側延伸'],
    holdSeconds: 30,
    sets: 2,
  ),
];
