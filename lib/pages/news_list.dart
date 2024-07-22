import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsList extends StatefulWidget {
  final List data;

  NewsList({required this.data});

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results', style: GoogleFonts.poppins(color: Colors.black),),
        backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.builder(
          itemCount: widget.data.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(widget.data[index]['title']),
                subtitle:
                Text('Published on: ${widget.data[index]['published_date']}'),
              ),
            );
          },
        ),
      ),
    );
  }
}