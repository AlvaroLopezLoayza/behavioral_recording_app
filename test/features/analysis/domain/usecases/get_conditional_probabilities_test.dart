import 'package:behavioral_recording_app/features/abc_recording/domain/entities/abc_record.dart';
import 'package:behavioral_recording_app/features/abc_recording/domain/entities/behavior_occurrence.dart';
import 'package:behavioral_recording_app/features/abc_recording/domain/repositories/abc_recording_repository.dart';
import 'package:behavioral_recording_app/features/analysis/domain/usecases/get_conditional_probabilities.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_conditional_probabilities_test.mocks.dart';

@GenerateMocks([AbcRecordingRepository])
void main() {
  late GetConditionalProbabilities usecase;
  late MockAbcRecordingRepository mockRepository;

  setUp(() {
    mockRepository = MockAbcRecordingRepository();
    usecase = GetConditionalProbabilities(mockRepository);
  });

  const tBehaviorId = 'test_behavior_1';
  
  final tOccurrence = BehaviorOccurrence(startTime: DateTime.now());
  
  final tRecords = [
    AbcRecord(
      id: '1',
      behaviorDefinitionId: tBehaviorId,
      antecedent: const {'description': 'Demand'},
      consequence: const {'description': 'Escape'},
      behaviorOccurrence: tOccurrence,
      recordingType: RecordingType.event,
      observerId: 'obs1',
      timestamp: DateTime.now(),
    ),
    AbcRecord(
      id: '2',
      behaviorDefinitionId: tBehaviorId,
      antecedent: const {'description': 'Demand'},
      consequence: const {'description': 'Escape'},
      behaviorOccurrence: tOccurrence,
      recordingType: RecordingType.event,
      observerId: 'obs1',
      timestamp: DateTime.now(),
    ),
    AbcRecord(
      id: '3',
      behaviorDefinitionId: tBehaviorId,
      antecedent: const {'description': 'Play'},
      consequence: const {'description': 'Attention'},
      behaviorOccurrence: tOccurrence,
      recordingType: RecordingType.event,
      observerId: 'obs1',
      timestamp: DateTime.now(),
    ),
  ];

  test('should return correct probabilities', () async {
    // arrange
    when(mockRepository.getRecordsByBehavior(any))
        .thenAnswer((_) async => Right(tRecords));

    // act
    final result = await usecase(const Params(behaviorId: tBehaviorId));

    // assert
    expect(result.isRight(), true);
    result.fold((l) => fail('Should be right'), (r) {
      expect(r.totalOccurrences, 3);
      
      // Antecedents: Demand (2/3 = 0.66), Play (1/3 = 0.33)
      final demandAnt = r.antecedentProbabilities.firstWhere((i) => i.name == 'Demand');
      expect(demandAnt.count, 2);
      expect(demandAnt.probability, closeTo(0.66, 0.01));
      
      // Consequences: Escape (2/3 = 0.66), Attention (1/3 = 0.33)
      final escapeCons = r.consequenceProbabilities.firstWhere((i) => i.name == 'Escape');
      expect(escapeCons.count, 2);
      expect(escapeCons.probability, closeTo(0.66, 0.01));
    });
  });
}
