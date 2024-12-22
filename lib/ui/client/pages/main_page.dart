import 'package:flutter/material.dart';
import '../widgets/product_list.dart';
import 'package:cash_control/constant.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  
  String searchQuery = "";
  List<String> filters = ['Овощи', 'Фрукты'];
  String selectedFilter = 'Овощи';

  void _searchProduct(String query) {
    setState(() {
      searchQuery = query;
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Поиск в магазине',
            hintStyle: headingStyle,
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
          onChanged: _searchProduct,
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.filter_alt, color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) searchController.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text(filter, style: bodyTextStyle),
                    selected: selectedFilter == filter,
                    selectedColor: primaryColor,
                    backgroundColor: Colors.grey.shade200,
                    onSelected: (isSelected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ProductListPage(searchQuery: searchQuery),
          ),
        ],
      ),
    );
  }
}
