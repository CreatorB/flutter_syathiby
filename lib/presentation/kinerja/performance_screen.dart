import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/staff/kinerja.dart';
import 'package:syathiby/presentation/kinerja/performance_controller.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../utils/widgets/sliver_appbar_delegate.dart';
import 'item_performance.dart';

class PerformanceScreen extends HookConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final performancePagingController =
        useMemoized(() => PagingController<int, Kinerja>(firstPageKey: 1));
    final fetchPerformanceDetail =
        ref.watch(fetchPerformanceDetailProvider(key: key));
    final touchedIndex = useState<int>(-1);

    Future<void> fetchPerformance(int pageKey, int pageSize) async {
      try {
        final result = await ref.watch(
          fetchStaffPerformanceProvider(
            key: key,
            limit: pageSize,
            page: pageKey,
          ).future,
        );
        final isLastPage = result.length < pageSize;
        if (isLastPage) {
          performancePagingController.appendLastPage(result);
        } else {
          final nextPageKey = pageKey + result.length;
          performancePagingController.appendPage(result, nextPageKey);
        }
      } catch (error) {
        performancePagingController.error = error;
      }
    }

    useEffect(() {
      performancePagingController.addPageRequestListener((pageKey) {
        fetchPerformance(pageKey, 20);
      });
      return null;
    }, []);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            performancePagingController.refresh();
            return ref.refresh(fetchPerformanceDetailProvider(key: key).future);
          },
          child: Skeletonizer(
            enabled: fetchPerformanceDetail.isLoading,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: context.colorPrimaryContainer,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40.0),
                          CustomAvatar(
                            name:
                                '${fetchPerformanceDetail.valueOrNull?.firstOrNull?.fullName}',
                            size: 60,
                            imageUrl:
                                '${fetchPerformanceDetail.valueOrNull?.firstOrNull?.img}',
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            '${fetchPerformanceDetail.valueOrNull?.firstOrNull?.fullName}',
                            style: TextStyle(
                              color: context.colorOnPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${fetchPerformanceDetail.valueOrNull?.firstOrNull?.kinerja}',
                            style: TextStyle(
                              color: context.colorPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  title: Text('Kinerja'.hardcoded),
                  floating: true,
                ),
                SliverPersistentHeader(
                  delegate: SliverAppBarDelegate(
                    TabBar(
                      tabs: [
                        Tab(text: 'List Penilaian'.hardcoded),
                        Tab(text: 'Data Penilaian'.hardcoded),
                        Tab(text: 'Grafik'.hardcoded),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    children: [
                      _tabOne(performancePagingController),
                      _tabTwo(fetchPerformanceDetail),
                      _tabThree(
                        context,
                        fetchPerformanceDetail.value ?? [],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabOne(PagingController<int, Kinerja> performancePagingController) {
    return PagedListView(
      physics: const NeverScrollableScrollPhysics(),
      pagingController: performancePagingController,
      builderDelegate: PagedChildBuilderDelegate<Kinerja>(
        itemBuilder: (context, item, index) => ItemPerformanceWidget(
          performance: item,
        ),
      ),
    );
  }

  Widget _tabTwo(AsyncValue<List<Kinerja>> fetchPerformanceDetail) {
    return fetchPerformanceDetail.when(
      data: (data) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return ItemPerformanceWidget(
            performance: item,
          );
        },
      ),
      error: (err, stack) => Center(
        child: Text('$err'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _tabThree(
    BuildContext context,
    List<Kinerja> list,
  ) {
    Map<String, double> data = {};
    for (var element in list) {
      final score = double.tryParse('${element.bobot}') ?? 0.0;
      data['${element.namaKinerja}'] = score >= 0 ? score : 0;
    }

    return PieChart(
      dataMap: data,
      animationDuration: const Duration(milliseconds: 800),
      chartLegendSpacing: 24,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      initialAngleInDegree: 0,
      chartType: ChartType.disc,
      ringStrokeWidth: 24,
      legendOptions: const LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.bottom,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: true,
        showChartValuesOutside: true,
        decimalPlaces: 1,
      ),
    );
  }
}
