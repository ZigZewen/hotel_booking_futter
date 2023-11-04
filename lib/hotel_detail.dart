import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'main.dart';

class HotelDetailPage extends StatefulWidget {
  final Hotel hotel;

  HotelDetailPage({required this.hotel});

  @override
  _HotelDetailPageState createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  final TextEditingController guestNameController = TextEditingController();
  DateTime? checkInDate;
  DateTime? checkOutDate;
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController checkInDateController = TextEditingController();
  final TextEditingController checkOutDateController = TextEditingController();

  Future<void> _selectCheckInDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: checkInDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != checkInDate) {
      setState(() {
        checkInDate = picked;
        checkInDateController.text =
            DateFormat('yyyy-MM-dd').format(checkInDate!);
      });
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: checkOutDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != checkOutDate) {
      setState(() {
        checkOutDate = picked;
        checkOutDateController.text =
            DateFormat('yyyy-MM-dd').format(checkOutDate!);
      });
    }
  }

  Future<void> bookHotel(BuildContext context) async {
    if (checkInDate == null || checkOutDate == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Date Selection Error'),
            content: Text('Please select both check-in and check-out dates.'),
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final Map<String, dynamic> bookingData = {
      "hotel_id": widget.hotel.id,
      "guest_name": guestNameController.text,
      "check_in_date": DateFormat('yyyy-MM-dd').format(checkInDate!),
      "check_out_date": DateFormat('yyyy-MM-dd').format(checkOutDate!),
      "phone_number": phoneController.text,
    };

    final response = await http.post(
      Uri.parse('http://localhost:3000/api/bookings'),
      body: json.encode(bookingData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Booking successful
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Booking Successful'),
                content: Text('Your hotel room has been booked.'),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text('OK'),
                    onPressed: () {
                      // Navigate back to the hotel list page
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ]);
          });
    } else {
      // Handle booking error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Booking Error'),
            content: Text('Failed to book the hotel room. Please try again.'),
            actions: <Widget>[
              ElevatedButton(
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel Detail'),
      ),
      body: SingleChildScrollView(
        child: Card(
          elevation: 4,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(widget.hotel.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hotel.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.hotel.address,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '\$${widget.hotel.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Show booking dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Book Hotel'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: guestNameController,
                                      decoration: InputDecoration(
                                          labelText: 'Guest Name'),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            readOnly: true,
                                            controller: checkInDateController,
                                            decoration: InputDecoration(
                                                labelText: 'Check-In Date'),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _selectCheckInDate(context),
                                          child: Text('Select'),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            readOnly: true,
                                            controller: checkOutDateController,
                                            decoration: InputDecoration(
                                                labelText: 'Check-Out Date'),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _selectCheckOutDate(context),
                                          child: Text('Select'),
                                        ),
                                      ],
                                    ),
                                    TextField(
                                      controller: phoneController,
                                      decoration:
                                          InputDecoration(labelText: 'Phone'),
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      bookHotel(context);
                                    },
                                    child: Text('Book Hotel'),
                                  ),
                                  ElevatedButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Book Hotel'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
