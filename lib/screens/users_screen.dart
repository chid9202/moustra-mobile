import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/user_list_constants.dart';
import 'package:moustra/services/dtos/user_list_dto.dart';
import 'package:moustra/services/clients/users_api.dart';
import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/widgets/shared/button.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';

final usersApi = UsersApi(apiClient);

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final PaginatedGridController _controller = PaginatedGridController();

  @override
  void initState() {
    super.initState();
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                MoustraButton.icon(
                  label: 'Create User',
                  icon: Icons.add,
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    if (context.mounted) {
                      context.go('/users/new');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: PaginatedDataGrid<UserListDto>(
            controller: _controller,
            onSortChanged: (columnName, ascending) {
              _controller.reload();
            },
            columns: UserListColumn.getColumns(),
            sourceBuilder: (rows) =>
                _UserGridSource(records: rows, context: context),
            fetchPage: (page, pageSize) async {
              final pageData = await usersApi.getUsers();
              return PaginatedResult<UserListDto>(
                count: pageData.length,
                results: pageData,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserGridSource extends DataGridSource {
  final List<UserListDto> records;
  final BuildContext context;

  _UserGridSource({required this.records, required this.context}) {
    _dataGridRows = records.map(UserListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _dataGridRows;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final String status = row.getCells()[5].value as String;

    return DataGridRowAdapter(
      cells: [
        Center(
          child: IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit User',
            onPressed: () {
              final String accountUuid = records
                  .where((user) => user.accountId == row.getCells()[0].value)
                  .first
                  .accountUuid;
              context.go('/users/$accountUuid');
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[1].value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[2].value),
        ),
        Center(child: Text(row.getCells()[3].value)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(row.getCells()[4].value),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Active' ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
