import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:syathiby/models/health/health.dart';
import 'package:syathiby/models/service_injection.dart';

part 'paging_student_health_controller.g.dart';

@riverpod
class PagingStudentHealthController extends _$PagingStudentHealthController {
  @override
  PagingController<int, Kesehatan> build({required String key}) {

    final pagingController = PagingController<int, Kesehatan>(firstPageKey: 1);

    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, key);
    });

    ref.onDispose(() {
      pagingController.dispose();
    });

    return pagingController;
  }

  Future<void> _fetchPage(int pageKey, String userKey) async {

    final pagingController = state;
    if (pagingController == null) return;

    try {

      final newItems =
          await ref.read(healthServiceProvider).get(userKey, pageKey);

      final isLastPage = newItems.isEmpty;

      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {

        final nextPageKey = pageKey + 1;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }
}