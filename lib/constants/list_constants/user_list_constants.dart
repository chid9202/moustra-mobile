import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/services/dtos/user_list_dto.dart';

class UserListColumn {
  static List<GridColumn> getColumns() {
    return [
      // GridColumn(
      //   columnName: 'accountId',
      //   label: Container(
      //     padding: const EdgeInsets.all(8.0),
      //     alignment: Alignment.centerLeft,
      //     child: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
      //   ),
      // ),
      GridColumn(
        columnName: 'name',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Name',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GridColumn(
        columnName: 'email',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Email',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GridColumn(
        columnName: 'role',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Role',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GridColumn(
        columnName: 'position',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Position',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GridColumn(
        columnName: 'status',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ];
  }

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
