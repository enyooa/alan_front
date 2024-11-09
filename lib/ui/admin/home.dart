import 'package:cash_control/bloc/blocs/product_bloc.dart';
import 'package:cash_control/bloc/services/organization_service.dart';
import 'package:cash_control/bloc/services/unit_service.dart';
import 'package:cash_control/ui/admin/form_pages/product_form_page.dart';
import 'package:cash_control/ui/main/repositories/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/organization_bloc.dart';
import 'package:cash_control/bloc/blocs/unit_bloc.dart';
import 'package:cash_control/ui/admin/dynamic_form_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  final organizationService = OrganizationService();
  final unitService = UnitService();

  runApp(GroceryApp(
    organizationService: organizationService,
    unitService: unitService,
  ));
}

class GroceryApp extends StatelessWidget {
  final OrganizationService organizationService;
  final UnitService unitService;

  const GroceryApp({
    Key? key,
    required this.organizationService,
    required this.unitService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
                BlocProvider(create: (context) => ProductBloc(ProductRepository())),

        BlocProvider(
          create: (context) => OrganizationBloc(organizationService: organizationService),
        ),
        BlocProvider(
          create: (context) => UnitBloc(unitService: unitService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.green,
          textTheme: GoogleFonts.montserratTextTheme(),
        ),
        home: ProductFormPage(),
      ),
    );
  }
}
