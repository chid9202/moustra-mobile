import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/favorite_dto.dart';

void main() {
  group('FavoriteDto', () {
    test('fromJson and toJson round-trip', () {
      final json = {
        'favoriteUuid': 'fav-1',
        'objectType': 'animal',
        'objectUuid': 'animal-uuid',
        'createdDate': '2024-06-01T10:00:00.000Z',
      };
      final dto = FavoriteDto.fromJson(json);
      expect(dto.favoriteUuid, 'fav-1');
      expect(dto.objectType, 'animal');
      expect(dto.objectUuid, 'animal-uuid');
      expect(dto.createdDate.toUtc().year, 2024);

      final out = dto.toJson();
      expect(out['favoriteUuid'], 'fav-1');
      expect(out['objectType'], 'animal');
      expect(out['objectUuid'], 'animal-uuid');
      expect(out['createdDate'], isA<String>());
    });
  });
}
