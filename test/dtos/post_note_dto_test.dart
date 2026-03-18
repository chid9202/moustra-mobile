import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/post_note_dto.dart';

void main() {
  group('PostNoteDto', () {
    test('fromJson with complete data', () {
      final json = {
        'content': 'This is a test note',
      };

      final dto = PostNoteDto.fromJson(json);

      expect(dto.content, equals('This is a test note'));
    });

    test('toJson round-trip', () {
      final dto = PostNoteDto(content: 'Another note');

      final output = dto.toJson();

      expect(output['content'], equals('Another note'));
    });

    test('fromJson then toJson preserves values', () {
      final json = {
        'content': 'Round trip note',
      };

      final dto = PostNoteDto.fromJson(json);
      final output = dto.toJson();

      expect(output['content'], equals(json['content']));
    });
  });
}
