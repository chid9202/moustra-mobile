import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/list_constants/user_list_constants.dart';
import 'package:moustra/services/dtos/user_list_dto.dart';

void main() {
  group('UserListColumn', () {
    group('getColumns', () {
      test('should return 6 columns', () {
        final columns = UserListColumn.getColumns();
        expect(columns.length, 6);
      });

      test('columns have expected column names', () {
        final columns = UserListColumn.getColumns();
        final columnNames = columns.map((c) => c.columnName).toList();
        expect(columnNames, contains('accountId'));
        expect(columnNames, contains('name'));
        expect(columnNames, contains('email'));
        expect(columnNames, contains('role'));
        expect(columnNames, contains('position'));
        expect(columnNames, contains('status'));
      });
    });

    group('getDataGridRow', () {
      UserListDto createUser({
        int accountId = 1,
        String accountUuid = 'uuid-1',
        String firstName = 'John',
        String lastName = 'Doe',
        String email = 'john@example.com',
        String status = 'active',
        String role = 'admin',
        String? position,
      }) {
        return UserListDto(
          accountId: accountId,
          accountUuid: accountUuid,
          user: UserDto(
            email: email,
            firstName: firstName,
            lastName: lastName,
            isActive: true,
          ),
          status: status,
          role: role,
          isActive: true,
          position: position,
          accountSetting: AccountSettingDto(
            enableDailyReport: false,
            onboardingTour: false,
            animalCreationTour: false,
          ),
          onboarded: true,
          lab: LabDto(labId: 1, labUuid: 'lab-uuid', labName: 'Test Lab'),
        );
      }

      test('produces correct number of cells', () {
        final user = createUser();
        final row = UserListColumn.getDataGridRow(user);
        // 6 cells: accountId, name, email, role, position, status
        expect(row.getCells().length, 6);
      });

      test('cell values are set correctly', () {
        final user = createUser(
          accountId: 42,
          firstName: 'Jane',
          lastName: 'Smith',
          email: 'jane@example.com',
          role: 'researcher',
          position: 'PI',
          status: 'active',
        );

        final row = UserListColumn.getDataGridRow(user);
        final cells = row.getCells();

        final accountIdCell = cells.firstWhere((c) => c.columnName == 'accountId');
        expect(accountIdCell.value, 42);

        final nameCell = cells.firstWhere((c) => c.columnName == 'name');
        expect(nameCell.value, 'Jane Smith');

        final emailCell = cells.firstWhere((c) => c.columnName == 'email');
        expect(emailCell.value, 'jane@example.com');

        final roleCell = cells.firstWhere((c) => c.columnName == 'role');
        expect(roleCell.value, 'researcher');

        final positionCell = cells.firstWhere((c) => c.columnName == 'position');
        expect(positionCell.value, 'PI');

        final statusCell = cells.firstWhere((c) => c.columnName == 'status');
        expect(statusCell.value, 'active');
      });

      test('handles null position with empty string fallback', () {
        final user = createUser(position: null);

        final row = UserListColumn.getDataGridRow(user);
        final cells = row.getCells();
        final positionCell = cells.firstWhere((c) => c.columnName == 'position');
        expect(positionCell.value, '');
      });

      test('name combines firstName and lastName', () {
        final user = createUser(firstName: 'Alice', lastName: 'Wonder');

        final row = UserListColumn.getDataGridRow(user);
        final cells = row.getCells();
        final nameCell = cells.firstWhere((c) => c.columnName == 'name');
        expect(nameCell.value, 'Alice Wonder');
      });
    });
  });
}
