import 'package:cash_control/bloc/blocs/packer_page_blocs/events/couriers_event.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/repo/courier_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/blocs/couriers_bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/states/couriers_state.dart';
import 'package:cash_control/constant.dart';

class CourierScreen extends StatefulWidget {
  const CourierScreen({Key? key}) : super(key: key);

  @override
  State<CourierScreen> createState() => _CourierScreenState();
}

class _CourierScreenState extends State<CourierScreen> {
  @override
  void initState() {
    context.read<CourierBloc>().add(FetchCouriersEvent());

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Курьеры',
          style: headingStyle,
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 4,
      ),
      body: BlocBuilder<CourierBloc, CourierState>(
        builder: (context, state) {
          if (state is CourierLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CourierError) {
            return Center(child: Text('Ошибка: ${state.message}', style: bodyTextStyle));
          } else if (state is CourierLoaded) {
            final couriers = state.couriers;
    
            if (couriers.isEmpty) {
              return const Center(child: Text('Нет курьеров', style: bodyTextStyle));
            }
    
            return ListView.builder(
              itemCount: couriers.length,
              itemBuilder: (context, index) {
                final courier = couriers[index];
                final addresses = courier['addresses'] as List<dynamic>;
    
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Text(
                        courier['first_name'][0],
                        style: buttonTextStyle,
                      ),
                    ),
                    title: Text(
                      '${courier['first_name']} ${courier['last_name']}',
                      style: subheadingStyle,
                    ),
                    subtitle: Text(
                      addresses.isNotEmpty
                          ? addresses.map((addr) => addr['name']).join(', ')
                          : 'Адреса не указаны',
                      style: bodyTextStyle,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: unselectednavbar,
                      size: 16,
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
