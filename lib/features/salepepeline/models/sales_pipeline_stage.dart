import 'package:flutter/material.dart';

class SalesPipelineStage {
  final String id;
  final String name;
  final int order;
  final Color? color;

  const SalesPipelineStage({
    required this.id,
    required this.name,
    required this.order,
    this.color,
  });

  static const defaults = <SalesPipelineStage>[
    SalesPipelineStage(
      id: 'prospecting',
      name: 'Prospecting',
      order: 1,
      color: Color(0xFF2F80ED),
    ),
    SalesPipelineStage(
      id: 'qualification',
      name: 'Qualification',
      order: 2,
      color: Color(0xFF9B51E0),
    ),
    SalesPipelineStage(
      id: 'proposal',
      name: 'Proposal',
      order: 3,
      color: Color(0xFFF2994A),
    ),
    SalesPipelineStage(
      id: 'closed',
      name: 'Closed',
      order: 4,
      color: Color(0xFF219653),
    ),
  ];
}
