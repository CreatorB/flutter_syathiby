import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/event/event.dart';
import 'package:syathiby/presentation/absen_asrama/hostel_controller.dart';
import 'package:syathiby/presentation/penjemputan/event_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';

class EventScreen extends HookConsumerWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllHostelAttendanceProvider(key: key),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final pagingController = useMemoized(
      () => PagingController<int, Event>(
        firstPageKey: 1,
      ),
    );

    Future<void> fetchData(int pageKey) async {
      try {
        final result = await ref.watch(
          fetchAllEventProvider(key: key, page: pageKey).future,
        );
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(result, nextPageKey);
      } catch (error) {
        pagingController.error = error;
      }
    }

    useEffect(() {
      pagingController.addPageRequestListener((pageKey) {
        fetchData(pageKey);
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Pondok'.hardcoded),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(fetchAllHostelAttendanceProvider(key: key).future),
        child: PagedListView(
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<Event>(
            itemBuilder: (context, event, index) {
              final startDate = ref.watch(
                formatDateProvider('${event.start_date}',
                    format: 'EEE, dd MMMM yyyy'),
              );
              final endDate = ref.watch(
                formatDateProvider('${event.finish_date}',
                    format: 'EEE, dd MMMM yyyy'),
              );

              return Card.outlined(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                  child: ListTile(
                    title: Text(
                      '${event.name_event}',
                      style: context.titleMediumBold,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$startDate s/d $endDate'),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Jumlah Murid: '),
                            Text('${event.jumlah} murid'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sudah Pulang: '),
                            Text('${event.dijemput} murid'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Murid Kembali: '),
                            Text('${event.dikembalikan} murid'),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      context.goNamed(
                        AppRoute.homecomingHostel.name,
                        queryParameters: {
                          'eventId': event.id_event,
                          'eventName': event.name_event,
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
