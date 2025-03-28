import 'package:alan/bloc/blocs/client_page_blocs/blocs/debts_report_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/financial_order_bloc.dart';
import 'package:alan/ui/client/widgets/financial_order.dart';
import 'package:alan/ui/client/widgets/order_items_widget.dart';
import 'package:alan/ui/client/widgets/reports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Blocs & States
import 'package:alan/bloc/blocs/client_page_blocs/blocs/client_order_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/client_order_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/client_order_state.dart';

import 'package:alan/bloc/blocs/client_page_blocs/blocs/price_offer_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/price_offer_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/price_offer_state.dart';

import 'package:alan/ui/client/widgets/price_offer_details.dart'; // If you have a separate PriceOfferDetailsPage
import 'package:alan/constant.dart';

class CalculationsPage extends StatefulWidget {
  const CalculationsPage({Key? key}) : super(key: key);

  @override
  _CalculationsPageState createState() => _CalculationsPageState();
}

class _CalculationsPageState extends State<CalculationsPage> {
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Fetch price offers and orders
    context.read<PriceOfferBloc>().add(const FetchPriceOffersEvent());
    context.read<ClientOrderBloc>().add(FetchClientOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // A) Full-page background (optional)
            Container(
              decoration: const BoxDecoration(
                // You could add a gradient or background color here
                // gradient: LinearGradient(
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                //   colors: [
                //     Color(0xFFECE9E6),
                //     Color(0xFFFFFFFF),
                //   ],
                // ),
              ),
            ),

            // B) Main content
            Column(
              children: [
                // 1) The Filter Header
                Padding(
                  padding: pagePadding,
                  child: _buildHeader(),
                ),

                // 2) The list of content
                Expanded(
                  child: _buildMainList(),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (routeContext) {
        return BlocProvider.value(
          value: context.read<FinancialOrderBloc>(), 
          child: const FinancialOrderWidget(),
        );
      }),
    );
  },
  child: const Icon(Icons.add),
),

    );
  }

  // ----------------------------------------------------------------------------
  // UPDATED HEADER WITH A "FILTER" ICON AND A "ОТЧЕТ ПО ДОЛГАМ" BUTTON
  // ----------------------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1) Icon + Dropdown for filtering
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.white),
              const SizedBox(width: 8),
              // The dropdown for "All", "PriceOffers", "Orders"
              DropdownButton<String>(
                value: selectedCategory,
                dropdownColor: primaryColor.withOpacity(0.9),
                style: subheadingStyle.copyWith(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items: const [
                  DropdownMenuItem(
                    value: 'All',
                    child: Text('Все', style: headingStyle),
                  ),
                  DropdownMenuItem(
                    value: 'PriceOffers',
                    child: Text('Предложения', style: headingStyle),
                  ),
                  DropdownMenuItem(
                    value: 'Orders',
                    child: Text('Заказы', style: headingStyle),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value ?? 'All';
                  });
                },
                underline: const SizedBox.shrink(),
              ),
            ],
          ),

          // 2) "Отчет по долгам" button
          ElevatedButton(
            onPressed: _showDebtsReport, // implement your logic here
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // or any color you like
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
            child: Text(
              "Отчет по долгам",
              style: subheadingStyle.copyWith(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  // Dummy method for "Отчет по долгам" button tap.
  // Replace with navigation or logic for your "debts report"
  void _showDebtsReport() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => DebtsReportBloc(),
        child: const DebtsReportPage(),
      ),
    ),
  );
}


  // ----------------------------------------------------------------------------
  // MAIN CONTENTS
  // ----------------------------------------------------------------------------
  Widget _buildMainList() {
    final List<Widget> contentWidgets = [];

    if (selectedCategory == 'All' || selectedCategory == 'PriceOffers') {
      contentWidgets.add(_buildPriceOffersSection());
    }
    if (selectedCategory == 'All' || selectedCategory == 'Orders') {
      contentWidgets.add(const SizedBox(height: 16));
      contentWidgets.add(_buildOrdersSection());
    }

    return ListView(
      padding: pagePadding,
      children: contentWidgets,
    );
  }

  // Price Offers Section
  Widget _buildPriceOffersSection() {
    return BlocBuilder<PriceOfferBloc, PriceOfferState>(
      builder: (context, state) {
        if (state is PriceOfferLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PriceOffersFetched) {
          final offers = state.priceOffers;
          if (offers.isEmpty) {
            return const Center(
              child: Text('Нет доступных предложений.', style: bodyTextStyle),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Предложения:', style: headingStyle),
              const SizedBox(height: 8),
              for (final offer in offers) _buildPriceOfferCard(offer),
            ],
          );
        } else if (state is PriceOfferError) {
          return Center(
            child: Text('Ошибка: ${state.message}', style: bodyTextStyle),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPriceOfferCard(Map<String, dynamic> offer) {
    final orderId = offer['id'];
    final startDate = offer['start_date'];
    final endDate = offer['end_date'];
    final totalSum = offer['totalsum']?.toString() ?? '0.00';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // gradient can be added if you want
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: () {
            // Navigate to price-offer details
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PriceOfferDetailsPage(offerOrder: offer),
              ),
            );
          },
          title: Text(
            'Предложение #$orderId',
            style: subheadingStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Период: $startDate - $endDate', style: captionStyle),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Сумма: $totalSum ₸',
                style: subheadingStyle.copyWith(color: primaryColor, fontSize: 15),
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        ),
      ),
    );
  }

  // Orders Section
  Widget _buildOrdersSection() {
    return BlocBuilder<ClientOrderBloc, ClientOrderState>(
      builder: (context, state) {
        if (state is ClientOrderLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ClientOrdersFetched) {
          final orders = state.orders;
          if (orders.isEmpty) {
            return const Center(
              child: Text('Нет доступных заказов.', style: bodyTextStyle),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Заказы:', style: headingStyle),
              const SizedBox(height: 8),
              for (final order in orders) _buildOrderCard(order),
            ],
          );
        } else if (state is ClientOrderError) {
          return Center(
            child: Text('Ошибка: ${state.message}', style: bodyTextStyle),
          );
        } else if (state is ClientOrderConfirmed) {
          // If an order was just confirmed, re-fetch
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ClientOrderBloc>().add(FetchClientOrdersEvent());
          });
          return Center(child: Text(state.message, style: bodyTextStyle));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id'];
    final statusId = order['status_id'] as int?;
    final address = order['address'] ?? 'Без адреса';
    final orderItems = order['order_items'] ?? [];

    double sum = 0.0;
    for (final item in orderItems) {
      final price = (item['price'] ?? 0).toDouble();
      final qty = (item['courier_quantity'] ?? 0).toDouble();
      sum += price * qty;
    }
    final bool isDone = (statusId == 4);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // gradient can be added if you want
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tappable area to see order details
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  splashColor: primaryColor.withOpacity(0.1),
                  onTap: () {
                    // Navigate to a details page (no confirm button inside)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsPage(order: order),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Заказ #$orderId',
                        style: subheadingStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: captionStyle.copyWith(color: Colors.grey.shade700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Сумма: ${sum.toStringAsFixed(2)} ₸',
                        style: subheadingStyle.copyWith(
                          color: primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right side: "Подтвердить" or "Исполнено"
              if (!isDone)
                ElevatedButton(
                  onPressed: () {
                    context.read<ClientOrderBloc>().add(ConfirmClientOrderEvent(orderId: orderId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Подтвердить', style: buttonTextStyle),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.done, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Исполнено', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
