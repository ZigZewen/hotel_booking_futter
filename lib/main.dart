import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'hotel_detail.dart'; // Import the BookingHistoryPage
import 'booking_history.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HotelList(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.red,
        fontFamily: 'Roboto',
      ),
    );
  }
}

class HotelList extends StatefulWidget {
  @override
  _HotelListState createState() => _HotelListState();
}

class _HotelListState extends State<HotelList> {
  List<Hotel> hotels = [];

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/hotels'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        hotels = jsonData.map((item) => Hotel.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load hotels');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel List'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // Navigate to the booking history page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BookingHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HotelDetailPage(hotel: hotels[index]),
                ),
              );
            },
            child: HotelCard(hotel: hotels[index]),
          );
        },
      ),
    );
  }
}

class HotelCard extends StatelessWidget {
  final Hotel hotel;

  HotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              image: DecorationImage(
                image: NetworkImage(hotel.image),
                fit: BoxFit.cover,
              ),
            ),
            height: 200,
          ),
          ListTile(
            title: Text(
              hotel.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              hotel.address,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            trailing: Text(
              '\$${hotel.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Hotel {
  final int id;
  final String name;
  final String address;
  final String image;
  final double price;

  Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.image,
    required this.price,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      image: json['image'],
      price: json['price'].toDouble(),
    );
  }
}
