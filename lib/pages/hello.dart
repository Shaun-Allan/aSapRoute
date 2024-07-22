import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final TextEditingController _controller = TextEditingController();

  void _sendData() async {
    String text = _controller.text;
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    print(text);
    print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    var response = await http.post(
      Uri.parse('http://192.168.53.189:5000/get_news'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'text': text,
      }),

    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      print(responseData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayPage(data: responseData),
        ),
      );
    } else {
      // Handle error
      print('Failed to load data');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter text',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendData,
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}





class DisplayPage extends StatelessWidget {
  final List data;

  DisplayPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(data[index]['title']),
                subtitle:
                Text('Published on: ${data[index]['published_date']}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
