import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/field_change_dto.dart';

class ChangesDiff extends StatelessWidget {
  final List<FieldChangeDto> changes;
  final bool compact;

  const ChangesDiff({
    super.key,
    required this.changes,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayChanges = compact && changes.length > 3
        ? changes.sublist(0, 3)
        : changes;
    final remaining = changes.length - 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayChanges.map((change) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(
                    '${change.label}: ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (change.oldValue != null)
                    Text(
                      change.oldValue!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                  if (change.oldValue != null && change.newValue != null)
                    Text(
                      ' → ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (change.newValue != null)
                    Text(
                      change.newValue!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                ],
              ),
            )),
        if (compact && remaining > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '+$remaining more',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
