import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/ui/client/widgets/price_offer_details.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/price_offer_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/price_offer_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/price_offer_state.dart';
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
    // Already triggered in MultiBlocProvider or you can do it here:
    context.read<PriceOfferBloc>().add(const FetchPriceOffersEvent());
  }

  Widget _buildDropdown() {
    return DropdownButton<String>(
      value: selectedCategory,
      dropdownColor: primaryColor.withOpacity(0.9),
      style: subheadingStyle.copyWith(color: Colors.white),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      items: const [
        DropdownMenuItem(value: 'All', child: Text('Все', style: headingStyle)),
        DropdownMenuItem(value: 'PriceOffers', child: Text('Предложения', style: headingStyle)),
        DropdownMenuItem(value: 'CourierDocuments', child: Text('Документы курьера', style: headingStyle)),
      ],
      onChanged: (value) {
        setState(() {
          selectedCategory = value ?? 'All';
        });
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8),
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
          Text('Фильтр:', style: headingStyle),
          _buildDropdown(),
        ],
      ),
    );
  }

  Widget _buildPriceOffers() {
    return BlocBuilder<PriceOfferBloc, PriceOfferState>(
      builder: (context, state) {
        if (state is PriceOfferLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PriceOffersFetched) {
          final orders = state.priceOffers;
          if (orders.isEmpty) {
            return const Center(child: Text('Нет доступных предложений.', style: bodyTextStyle));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['id'];
              final startDate = order['start_date'];
              final endDate = order['end_date'];
              final totalSum = order['totalsum']?.toString() ?? '0.00';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  onTap: () {
                    // Navigate to details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PriceOfferDetailsPage(offerOrder: order),
                      ),
                    );
                  },
                  title: Text(
                    'Предложение #$orderId',
                    style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Период: $startDate - $endDate', style: captionStyle),
                      const SizedBox(height: 4),
                      Text('Сумма: $totalSum ₸', style: subheadingStyle.copyWith(color: primaryColor)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ),
              );
            },
          );
        } else if (state is PriceOfferError) {
          return Center(child: Text('Ошибка: ${state.message}', style: bodyTextStyle));
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: pagePadding,
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildPriceOffers(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
