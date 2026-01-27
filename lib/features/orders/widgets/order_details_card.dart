import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/detail_row.dart';
import '../../../core/models/models.dart';

/// Card displaying order details (number, quantity, price, dates)
class OrderDetailsCard extends StatelessWidget {
  final Order order;

  const OrderDetailsCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Детали заказа',
      icon: Icons.info_outline,
      child: Column(
        children: [
          DetailRow(
            label: 'Номер заказа',
            value: '#${order.id.length >= 8 ? order.id.substring(0, 8) : order.id}',
          ),
          DetailRow(
            label: 'Количество',
            value: '${order.quantity} шт.',
          ),
          DetailRow(
            label: 'Стоимость',
            value: '${order.totalPrice.toStringAsFixed(0)} сом',
          ),
          if (order.dueDate != null)
            DetailRow(
              label: 'Дата сдачи',
              value: DateFormat('d MMMM yyyy', 'ru').format(order.dueDate!),
              valueColor: order.isOverdue ? AppColors.error : null,
            ),
          DetailRow(
            label: 'Создан',
            value: DateFormat('d MMMM yyyy', 'ru').format(order.createdAt),
          ),
        ],
      ),
    );
  }
}
