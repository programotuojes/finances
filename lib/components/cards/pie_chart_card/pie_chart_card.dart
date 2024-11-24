import 'package:finances/category/service.dart';
import 'package:finances/components/cards/pie_chart_card/pie_chart_layer.dart';
import 'package:finances/components/home_card.dart';
import 'package:finances/transaction/service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const pieChartCenterSpaceRadius = 70.0;

class PieChartCard extends StatefulWidget {
  final DateTimeRange dateRange;
  final List<PieChartLayer> _layers;

  PieChartCard({
    super.key,
    required this.dateRange,
  }) : _layers = [
          PieChartLayer(
            dateRangeFilter: dateRange,
            parent: CategoryService.instance.rootCategory,
          )
        ];

  @override
  State<PieChartCard> createState() => _PieChartCardState();
}

class _PieChartCardState extends State<PieChartCard> {
  var _clickedIndex = -1;
  var _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    Listenable.merge([CategoryService.instance, TransactionService.instance]).addListener(() {
      if (!mounted) {
        return;
      }

      setState(() {
        _clickedIndex = -1;
        _hoveredIndex = -1;
        widget._layers
          ..clear()
          ..add(PieChartLayer(
            dateRangeFilter: widget.dateRange,
            parent: CategoryService.instance.rootCategory,
          ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLayer = widget._layers.last;
    final sections = currentLayer.getSections(clickedIndex: _clickedIndex, hoveredIndex: _hoveredIndex).toList();

    return GestureDetector(
      onTap: () {
        setState(() {
          _clickedIndex = -1;
          _hoveredIndex = -1;
        });
      },
      child: HomeCard(
        title: 'Expenses by category',
        crossAxisAlignment: CrossAxisAlignment.stretch,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                if (sections.isEmpty)
                  Center(
                    child: Container(
                      height: 220,
                      width: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 40,
                          color: Colors.grey,
                        ),
                      ),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'No expenses found',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      currentLayer.getCenterText(clickedIndex: _clickedIndex, hoveredIndex: _hoveredIndex),
                      SizedBox(
                        height: 220,
                        width: 220,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              mouseCursorResolver: (event, response) {
                                final index = response?.touchedSection?.touchedSectionIndex ?? -1;

                                if (currentLayer.canClick(index)) {
                                  return SystemMouseCursors.click;
                                }

                                return MouseCursor.defer;
                              },
                              touchCallback: (event, pieTouchResponse) {
                                var index = pieTouchResponse?.touchedSection?.touchedSectionIndex ?? -1;

                                setState(() {
                                  if (event is FlTapUpEvent) {
                                    _clickedIndex = index;
                                  }

                                  if (!event.isInterestedForInteractions) {
                                    index = -1;
                                  }

                                  _hoveredIndex = index;
                                });
                              },
                            ),
                            centerSpaceRadius: pieChartCenterSpaceRadius,
                            sections: sections,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    for (var section in sections)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: section.color,
                              borderRadius: const BorderRadius.all(Radius.circular(4)),
                            ),
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              section.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                )
              ],
            ),
            if (widget._layers.length > 1)
              Align(
                alignment: Alignment.topLeft,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      widget._layers.removeLast();
                      _clickedIndex = -1;
                    });
                  },
                  child: const Text('Go back'),
                ),
              ),
            if (currentLayer.canClick(_clickedIndex))
              Align(
                alignment: Alignment.topRight,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      if (_clickedIndex == -1) {
                        // Sometimes the _clickedIndex is -1 here
                        // Perhaps a race condition?
                        // Simplest solution - ignore it and just make the user click again
                        return;
                      }

                      widget._layers.add(currentLayer.createNewLayer(_clickedIndex));
                      _clickedIndex = -1;
                    });
                  },
                  child: const Text('Go deeper'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
