import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/list_constants/common.dart';
import 'package:moustra/constants/list_constants/user_list_constants.dart';
import 'package:moustra/services/dtos/user_list_dto.dart';
import 'package:moustra/services/clients/users_api.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/stores/table_setting_store.dart';
import 'package:moustra/widgets/column_settings_sheet.dart';
import 'package:moustra/widgets/shared/button.dart';
import 'package:moustra_api/moustra_api.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:moustra/widgets/paginated_datagrid.dart';
import 'package:moustra/services/clients/event_api.dart';

final usersApi = UsersApi(dioApiClient);

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final PaginatedGridController _controller = PaginatedGridController();

  // Table settings
  TableSettingSLR? _tableSetting;

  @override
  void initState() {
    super.initState();
    eventApi.trackEvent('view_users');
    _controller.reload();
    _loadTableSetting();
  }

  Future<void> _loadTableSetting() async {
    final setting = await getTableSetting('UserList');
    if (mounted && setting != null) {
      setState(() => _tableSetting = setting);
    }
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
                      context.go('/user/new');
                    }
                  },
                ),
                if (_tableSetting != null)
                  MoustraButton.icon(
                    label: 'Columns',
                    icon: Icons.view_column,
                    variant: ButtonVariant.secondary,
                    onPressed: () => showColumnSettingsSheet(
                      context: context,
                      baseName: 'UserList',
                      tableSetting: _tableSetting!,
                      onSettingsChanged: () {
                        final updated = tableSettingStore.value['UserList'];
                        if (updated != null && mounted) {
                          setState(() => _tableSetting = updated);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Builder(builder: (context) {
            final columns = buildColumnsFromSettings(
              _tableSetting?.tableSettingFields.toList(),
            );
            return PaginatedDataGrid<UserListDto>(
            onRowTap: (user) {
              context.go('/user/${user.accountUuid}');
            },
            controller: _controller,
            onSortChanged: (columnName, ascending) {
              _controller.reload();
            },
            columns: columns,
            sourceBuilder: (rows) =>
                _UserGridSource(records: rows, context: context, columns: columns),
            fetchPage: (page, pageSize) async {
              final pageData = await usersApi.getUsers();
              return PaginatedResult<UserListDto>(
                count: pageData.length,
                results: pageData,
              );
            },
          );
          }),
        ),
      ],
    );
  }
}

class _UserGridSource extends DataGridSource {
  final List<UserListDto> records;
  final BuildContext context;
  final List<GridColumn> columns;

  _UserGridSource({
    required this.records,
    required this.context,
    required this.columns,
  }) {
    _dataGridRows = records.map(UserListColumn.getDataGridRow).toList();
  }

  late List<DataGridRow> _dataGridRows;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final Map<String, Object?> values = {
      for (final cell in row.getCells()) cell.columnName: cell.value,
    };
    final String status = (values['status'] as String?) ?? '';

    Widget buildCell(String columnName) {
      switch (columnName) {
        case 'name':
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text((values['name'] as String?) ?? ''),
          );
        case 'email':
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text((values['email'] as String?) ?? ''),
          );
        case 'role':
          return Center(child: Text((values['role'] as String?) ?? ''));
        case 'position':
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text((values['position'] as String?) ?? ''),
          );
        case 'status':
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status == 'Active' ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        default:
          return const SizedBox.shrink();
      }
    }

    return DataGridRowAdapter(
      cells: columns.map((col) => buildCell(col.columnName)).toList(),
    );
  }
}
