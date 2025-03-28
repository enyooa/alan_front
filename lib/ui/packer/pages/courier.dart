import 'package:alan/bloc/blocs/packer_page_blocs/events/all_instances_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/repo/all_instances_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/all_instances_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/all_instances_state.dart';
import 'package:alan/constant.dart';

class CourierScreen extends StatefulWidget {
  const CourierScreen({Key? key}) : super(key: key);

  @override
  State<CourierScreen> createState() => _CourierScreenState();
}

class _CourierScreenState extends State<CourierScreen> {
  @override
  void initState() {
    context.read<AllInstancesBloc>().add(FetchAllInstancesEvent());

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
      body: BlocBuilder<AllInstancesBloc, AllInstancesState>(
        builder: (context, state) {
          if (state is AllInstancesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AllInstancesError) {
            return Center(child: Text('Ошибка: ${state.message}', style: bodyTextStyle));
          } else if (state is AllInstancesLoaded) {
            final couriers = state.data;
    
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
