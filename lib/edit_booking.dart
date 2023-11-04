import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EditBookingPage extends StatefulWidget {
  final int bookingId;

  EditBookingPage({required this.bookingId});

  @override
  _EditBookingPageState createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  TextEditingController guestNameController = TextEditingController();
  TextEditingController checkInDateController = TextEditingController();
  TextEditingController checkOutDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBookingData();
  }

  Future<void> fetchBookingData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/bookings/${widget.bookingId}'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        guestNameController.text = jsonData['guest_name'];
        checkInDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.parse(jsonData['check_in_date']));
        checkOutDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.parse(jsonData['check_out_date']));
      });
    } else {
      throw Exception('Failed to load booking data');
    }
  }

  Future<void> updateBooking() async {
    final updatedBooking = {
      'guest_name': guestNameController.text,
      'check_in_date': checkInDateController.text,
      'check_out_date': checkOutDateController.text,
    };

    final response = await http.put(
      Uri.parse('http://localhost:3000/api/bookings/${widget.bookingId}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedBooking),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Update Failed'),
            content: Text('Failed to update booking. Please try again.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    guestNameController.dispose();
    checkInDateController.dispose();
    checkOutDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guest Name'),
            TextFormField(
              controller: guestNameController,
              decoration: InputDecoration(
                hintText: 'Enter guest name',
              ),
            ),
            SizedBox(height: 16.0),
            Text('Check-In Date'),
            TextFormField(
              controller: checkInDateController,
              decoration: InputDecoration(
                hintText: 'yyyy-MM-dd',
              ),
            ),
            SizedBox(height: 16.0),
            Text('Check-Out Date'),
            TextFormField(
              controller: checkOutDateController,
              decoration: InputDecoration(
                hintText: 'yyyy-MM-dd',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: updateBooking,
              child: Text('Update Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
