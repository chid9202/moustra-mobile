import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/note_dto.dart';

void main() {
  group('NoteDto', () {
    test('fromJson with optional createdBy and updatedDate', () {
      final json = {
        'noteUuid': 'n-1',
        'content': 'Hello',
        'createdDate': '2024-03-01T12:00:00.000Z',
        'createdBy': {
          'accountUuid': 'a1',
          'user': {
            'email': 'u@test.com',
            'firstName': 'U',
            'lastName': 'Ser',
          },
        },
        'updatedDate': '2024-03-02T15:00:00.000Z',
      };
      final dto = NoteDto.fromJson(json);
      expect(dto.noteUuid, 'n-1');
      expect(dto.content, 'Hello');
      expect(dto.createdBy?.accountUuid, 'a1');
      expect(dto.updatedDate, isNotNull);
    });

    test('toJson omits null optional fields', () {
      final dto = NoteDto(
        noteUuid: 'n-2',
        content: 'X',
        createdDate: DateTime.utc(2024, 1, 1),
      );
      final out = dto.toJson();
      expect(out['noteUuid'], 'n-2');
      expect(out['content'], 'X');
      expect(out['createdBy'], isNull);
      expect(out['updatedDate'], isNull);
    });
  });
}
