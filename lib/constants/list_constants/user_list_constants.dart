import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/services/dtos/user_list_dto.dart';

class UserListColumn {
  static DataGridRow getDataGridRow(UserListDto user) {
    return DataGridRow(
      cells: [
        DataGridCell(columnName: 'accountId', value: user.accountId),
        DataGridCell(
          columnName: 'name',
          value: '${user.user.firstName} ${user.user.lastName}',
        ),
        DataGridCell(columnName: 'email', value: user.user.email),
        DataGridCell(columnName: 'role', value: user.role),
        DataGridCell(columnName: 'position', value: user.position ?? ''),
        DataGridCell(columnName: 'status', value: user.status),
      ],
    );
  }
}
