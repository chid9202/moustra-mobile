import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moustra/widgets/state_widgets.dart';

/// Sealed class representing the state of an asynchronous operation.
sealed class AsyncValue<T> {
  const AsyncValue();

  factory AsyncValue.loading() = AsyncLoading<T>;
  factory AsyncValue.data(T value) = AsyncData<T>;
  factory AsyncValue.error(Object error) = AsyncError<T>;
}

class AsyncLoading<T> extends AsyncValue<T> {
  const AsyncLoading();
}

class AsyncData<T> extends AsyncValue<T> {
  final T value;
  const AsyncData(this.value);
}

class AsyncError<T> extends AsyncValue<T> {
  final Object error;
  const AsyncError(this.error);
}

/// A widget that builds different UIs based on the [AsyncValue] state.
/// Wraps a [ValueListenableBuilder] and provides default loading/error widgets.
class AsyncValueBuilder<T> extends StatelessWidget {
  final ValueListenable<AsyncValue<T>> valueListenable;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final VoidCallback? onRetry;

  const AsyncValueBuilder({
    super.key,
    required this.valueListenable,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AsyncValue<T>>(
      valueListenable: valueListenable,
      builder: (context, asyncValue, _) {
        return switch (asyncValue) {
          AsyncLoading() =>
            loadingBuilder?.call(context) ?? const AppLoadingWidget(),
          AsyncData(:final value) => builder(context, value),
          AsyncError(:final error) =>
            errorBuilder?.call(context, error) ??
                AppErrorWidget(
                  message: error.toString(),
                  onRetry: onRetry,
                ),
        };
      },
    );
  }
}
