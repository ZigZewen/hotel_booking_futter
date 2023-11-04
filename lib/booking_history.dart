import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'edit_booking.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BookingHistoryPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.red,
        fontFamily: 'Roboto',
      ),
    );
  }
}

class BookingHistoryPage extends StatefulWidget {
  @override
  _BookingHistoryPageState createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  List<Booking> bookings = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/bookings'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        bookings = jsonData.map((item) => Booking.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking History'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _refreshIndicatorKey.currentState?.show();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () => fetchBookings(),
        child: ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            return BookingCard(
              booking: bookings[index],
              onDelete: () => deleteBooking(index),
              onEdit: () => editBooking(bookings[index].id),
            );
          },
        ),
      ),
    );
  }

  Future<void> deleteBooking(int index) async {
    final int bookingId = bookings[index].id;
    final response = await http.delete(Uri.parse('http://localhost:3000/api/bookings/$bookingId'));

    if (response.statusCode == 204) {
      setState(() {
        bookings.removeAt(index);
      });
    }
  }

  void editBooking(int bookingId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditBookingPage(bookingId: bookingId),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  BookingCard({required this.booking, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        title: Text(
          booking.guestName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Check-In Date: ${DateFormat('yyyy-MM-dd').format(booking.checkInDate)}',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            Text(
              'Check-Out Date: ${DateFormat('yyyy-MM-dd').format(booking.checkOutDate)}',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Confirm Delete'),
                      content: Text('Are you sure you want to delete this booking?'),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Delete'),
                          onPressed: () {
                            onDelete();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Booking {
  final int id;
  final String guestName;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  Booking({
    required this.id,
    required this.guestName,
    required this.checkInDate,
    required this.checkOutDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['booking_id'],
      guestName: json['guest_name'] ?? 'Guest Name',
      checkInDate: DateTime.parse(json['check_in_date'] ?? '2000-01-01'),
      checkOutDate: DateTime.parse(json['check_out_date'] ?? '2000-01-02'),
    );
  }
}
