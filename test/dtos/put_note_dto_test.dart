import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/put_note_dto.dart';

void main() {
  group('PutNoteDto', () {
    test('fromJson with complete data', () {
      final json = {
        'content': 'Updated note content',
      };

      final dto = PutNoteDto.fromJson(json);

      expect(dto.content, equals('Updated note content'));
    });

    test('toJson round-trip', () {
      final dto = PutNoteDto(content: 'Some content');

      final output = dto.toJson();

      expect(output['content'], equals('Some content'));
    });

    test('fromJson then toJson preserves values', () {
      final json = {
        'content': 'Round trip content',
      };

      final dto = PutNoteDto.fromJson(json);
      final output = dto.toJson();

      expect(output['content'], equals(json['content']));
    });
  });
}
