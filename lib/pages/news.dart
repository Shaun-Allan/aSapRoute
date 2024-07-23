


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

enum SortOrder {
  Ascending,
  Descending
}

extension SortOrderExtension on SortOrder {
  String get name {
    switch (this) {
      case SortOrder.Ascending:
        return 'Ascending';
      case SortOrder.Descending:
        return 'Descending';
      default:
        return '';
    }
  }
}


enum SortOption {
  Alphabetical,
  PublishedDate
}

extension SortOptionExtension on SortOption {
  String get name {
    switch (this) {
      case SortOption.Alphabetical:
        return 'Alphabetical';
      case SortOption.PublishedDate:
        return 'Published Date';
      default:
        return '';
    }
  }
}

enum Publishers {
  HindustanTimes,
  TimesOfIndia,
  TheHindu,
  NDTV,
  IndianExpress,
  DeccanHerald,
  News18,
  Reuters,
  AlJazeera,
  IndiaToday,
  LiveMint,
  FloodList,
  Others
}

extension PublishersExtension on Publishers {
  String get name {
    switch (this) {
      case Publishers.Reuters:
        return 'Reuters';
      case Publishers.AlJazeera:
        return 'Al Jazeera';
      case Publishers.TheHindu:
        return 'The Hindu';
      case Publishers.TimesOfIndia:
        return 'Times of India';
      case Publishers.NDTV:
        return 'NDTV';
      case Publishers.IndiaToday:
        return 'India Today';
      case Publishers.HindustanTimes:
        return 'Hindustan Times';
      case Publishers.IndianExpress:
        return 'The Indian Express';
      case Publishers.DeccanHerald:
        return 'Deccan Herald';
      case Publishers.LiveMint:
        return 'LiveMint';
      case Publishers.News18:
        return 'News18';
      case Publishers.FloodList:
        return 'FloodList';
      case Publishers.Others:
        return 'Others';
      default:
        return '';
    }
  }
}



class _NewsState extends State<News> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<dynamic>? responseData;
  List<dynamic>? orgData;
  bool _loading = false;
  bool _searched = false;

  List<String> sortOptions = ['Alphabetical', 'Published Date'];
  List<String> orderOptions = ['Ascending', 'Descending'];
  SortOrder? selectedOrder = SortOrder.Ascending;
  SortOption? selectedOption = SortOption.Alphabetical;
  Publishers? selectedPublisher = Publishers.TimesOfIndia;

  String? selectedSortOption;
  String? selectedOrderOption;

  List<String> publisherOptions = [
    'https://www.livemint.com',
    'https://timesofindia.indiatimes.com',
    'https://www.thehindu.com',
    'https://www.deccanherald.com',
    'https://www.ndtv.com',
    'https://indianexpress.com',
    'https://floodlist.com',
    'https://www.aljazeera.com',
    'https://www.reuters.com',
    'https://www.hindustantimes.com',
    'https://www.indiatoday.in',
    'https://indianexpress.com',
    'https://www.news18.com',
    'Others'
  ];

  String? selectedPublisherOption;
  ScrollController _scrollController = ScrollController();
  TextEditingController _sortOrderController = TextEditingController();
  TextEditingController _sortOptionController = TextEditingController();
  TextEditingController _publisherController = TextEditingController();
  double _elevation = 0;

  @override
  void initState() {
    super.initState();
    selectedSortOption = sortOptions.first;
    selectedOrderOption = orderOptions.first;
    selectedPublisherOption = publisherOptions.first;
    _scrollController.addListener(() {
      setState(() {
        _elevation = _scrollController.offset > 0 ? 4 : 0; // Change elevation if scrolled down
      });
    });
  }

  void _sendData() async {
    setState(() {
      _loading = true;
      _searched = true;
      responseData = null;
    });

    String text = _controller.text;
    print(text);
    var response = await http.post(
      Uri.parse('http://samyuktaa2417.pythonanywhere.com/get_news_full'),

      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        responseData = jsonDecode(response.body);
        orgData = responseData;
        _loading = false;
      });
    } else {
      // Handle error
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Failed to load data');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    print("kjsdf");
    print(url);
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      // Handle error as needed, such as showing a dialog or logging the error.
    }
  }

  void _sortData() {
    if (responseData != null && responseData!.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(CupertinoIcons.sort_down),
                SizedBox(width: 20,),
                Text('Sort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text('Sort Option', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10,),
                  DropdownMenu<SortOption>(
                    // width: double.infinity,
                    width: MediaQuery.of(context).size.width - 128,
                    controller: _sortOptionController,
                    // leadingIcon: Icon(CupertinoIcons.exclamationmark_triangle, size: 25,),
                    // label: Text('', style: GoogleFonts.openSans(
                    //     fontSize: 16
                    // ),),
                    onSelected: (SortOption? sortOption) {
                      setState(() {
                        selectedOption = sortOption!;
                        print(selectedOption!.name);
                      });
                    },
                    initialSelection: selectedOption,
                    dropdownMenuEntries: SortOption.values
                        .map<DropdownMenuEntry<SortOption>>((SortOption sortOption) {
                      return DropdownMenuEntry<SortOption>(
                        value: sortOption,
                        label: sortOption.name,
                        style: MenuItemButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text('Order', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10,),
                  DropdownMenu<SortOrder>(
                    // width: double.infinity,
                    width: MediaQuery.of(context).size.width - 128,
                    controller: _sortOrderController,
                    // leadingIcon: Icon(CupertinoIcons.exclamationmark_triangle, size: 25,),
                    // label: Text('', style: GoogleFonts.openSans(
                    //     fontSize: 16
                    // ),),
                    onSelected: (SortOrder? sortOrder) {
                      setState(() {
                        selectedOrder = sortOrder!;
                        print(selectedOrder!.name);
                      });
                    },
                    initialSelection: selectedOrder,
                    dropdownMenuEntries: SortOrder.values
                        .map<DropdownMenuEntry<SortOrder>>((SortOrder sortOrder) {
                      return DropdownMenuEntry<SortOrder>(
                        value: sortOrder,
                        label: sortOrder.name,
                        style: MenuItemButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),

                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  _applySorting();
                  Navigator.of(context).pop(); // Close the dialog after applying sorting
                },
                child: Text('Apply', style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        },
      );
    } else {
      // Handle case when responseData is null or empty
      print('No data to sort');
    }
  }

  GlobalKey actionKey = GlobalKey();
  double? buttonWidth;


  void _applySorting() {
    var dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
    setState(() {
      if (selectedOption!.name == 'Alphabetical') {
        print(selectedOrder!.name);
        if (selectedOrder!.name == 'Ascending') {
          responseData!.sort((a, b) => a['title'].compareTo(b['title']));
        } else {
          responseData!.sort((a, b) => b['title'].compareTo(a['title']));
        }
      } else if (selectedOption!.name == 'Published Date') {
        if (selectedOrder!.name == 'Ascending') {
          responseData!.sort((a, b) {
            var dateA = dateFormat.parse(a['published date']);
            var dateB = dateFormat.parse(b['published date']);
            return dateA.compareTo(dateB);
          });
        } else {
          responseData!.sort((a, b) {
            var dateA = dateFormat.parse(a['published date']);
            var dateB = dateFormat.parse(b['published date']);
            return dateB.compareTo(dateA);
          });
        }
      }
    });
  }

  void _filterData() {
    if (responseData != null && responseData!.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Row(
                  children: [
                    Icon(FontAwesomeIcons.filter, size: 18,),
                    SizedBox(width: 20,),
                    Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text('Publisher', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10,),
                      DropdownMenu<Publishers>(
                        // width: double.infinity,
                        width: MediaQuery.of(context).size.width - 128,
                        controller: _publisherController,
                        // leadingIcon: Icon(CupertinoIcons.exclamationmark_triangle, size: 25,),
                        // label: Text('', style: GoogleFonts.openSans(
                        //     fontSize: 16
                        // ),),
                        onSelected: (Publishers? pub) {
                          setState(() {
                            selectedPublisher = pub!;
                            print(selectedOption!.name);
                          });
                        },
                        initialSelection: selectedPublisher,
                        dropdownMenuEntries: Publishers.values
                            .map<DropdownMenuEntry<Publishers>>((Publishers pub) {
                          return DropdownMenuEntry<Publishers>(
                            value: pub,
                            label: pub.name,
                            style: MenuItemButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel', style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () {
                      _applyFilter();
                      Navigator.of(context).pop(); // Close the dialog after applying sorting
                    },
                    child: Text('Apply', style: TextStyle(color: Colors.green)),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      // Handle case when responseData is null or empty
      print('No data to filter');
    }
  }

  void _applyFilter() {
    setState(() {
      print("org");
      print(orgData);
      responseData = orgData;
      print(responseData);
      if (selectedPublisher!.name != 'Others') {
        responseData!.removeWhere((item) => item['publisher']['title'] != selectedPublisher!.name);
      } else {
        // Filter for "Others" option
        List<String> validPublishers = [
          'https://www.livemint.com',
          'https://timesofindia.indiatimes.com',
          'https://www.thehindu.com',
          'https://www.deccanherald.com',
          'https://www.ndtv.com',
          'https://indianexpress.com',
          'https://floodlist.com',
          'https://www.aljazeera.com',
          'https://www.reuters.com',
          'https://www.hindustantimes.com',
          'https://www.indiatoday.in',
          'https://indianexpress.com',
          'https://www.news18.com',
        ];
        responseData!.removeWhere((item) => !Publishers.values.contains(item['publisher']['title']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   boxShadow: [
            //     BoxShadow(
            //       color: Colors.grey.withOpacity(0.5),
            //       spreadRadius: 5,
            //       blurRadius: 7,
            //       offset: Offset(0, 3), // changes position of shadow
            //     ),
            //   ],
            // ),
            padding: EdgeInsets.only(left: 15, right: 15, top: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Focus(
                    focusNode: _focusNode,
                    onFocusChange: (hasFocus) {
                      setState(() {});
                    },
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Enter keywords',
                        labelStyle: TextStyle(
                          color: _focusNode.hasFocus
                              ? Color.fromARGB(255, 0, 80, 0)
                              : Colors.black,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 0, 80, 0),
                              width: 100.0,
                          )
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 0, 80, 0), // Custom focus color
                            width: 2.0, // Width of the focused border
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(CupertinoIcons.search),
                          color: Color.fromARGB(255, 0, 80, 0),
                          onPressed: _sendData,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: responseData != null && responseData!.isNotEmpty ? _sortData : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: responseData != null && responseData!.isNotEmpty ? Color.fromARGB(255, 0, 80, 0) : Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              CupertinoIcons.sort_down,
                              color: responseData != null && responseData!.isNotEmpty ? Color.fromARGB(200, 34, 139, 34) : Colors.grey,
                            ),
                            Spacer(),
                            Text(
                              "Sort",
                              style: GoogleFonts.poppins(
                                color: responseData != null && responseData!.isNotEmpty ? Color.fromARGB(255, 0, 80, 0) : Colors.grey,
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: responseData != null && responseData!.isNotEmpty ? _filterData : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: responseData != null && responseData!.isNotEmpty ? Color.fromARGB(255, 0, 80, 0) : Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              FontAwesomeIcons.filter,
                              size: 18,
                              color: responseData != null && responseData!.isNotEmpty ? Color.fromARGB(200, 34, 139, 34) : Colors.grey,
                            ),
                            Spacer(),
                            Text(
                              'Filter',
                              style: GoogleFonts.poppins(
                                color: responseData != null && responseData!.isNotEmpty ? Color.fromARGB(255, 0, 80, 0) : Colors.grey,
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if(_loading || (_searched && responseData != null))
                  SizedBox(height: 12,)
                else
                  SizedBox(height: 5,)
              ],
            ),
          ),
          if(_loading || (_searched && responseData != null))
            Divider(height: 0, color: Colors.grey,),
          if(_elevation == 0)
            SizedBox(height: 8,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Expanded(
                child: _loading
                    ? ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: 7, // Number of skeleton items to show
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      elevation: 1.5,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: _buildCustomCardSkeleton(),
                          // child: ClipRRect(
                          //   borderRadius: BorderRadius.circular(10), // Rounded corners
                          //   child: Column(
                          //     children: [
                          //       _buildCustomCardSkeleton(),
                          //       Container(
                          //         height: 1,
                          //         margin: EdgeInsets.symmetric(horizontal: 15.0),
                          //         color: Colors.grey[300],
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ),
                      ),
                    );
                  },
                )
                    : responseData == null || responseData!.isEmpty
                    ? Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 0.5,
                                blurRadius: 20,
                                offset: Offset(0, 0), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.news,
                                color: Colors.grey,
                                size: 40,
                              ),
                              SizedBox(height: 20),
                              Text(
                                !_searched? "Your search results would appear here" : "No results for the given keywords",
                                style: GoogleFonts.lato(color: Colors.grey),
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15,)
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: responseData!.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _buildCustomCard(responseData![index]),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCard(Map<String, dynamic> data) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.5),
          width: 1,
        ),
      ),
      elevation: 1.5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['title'],
              style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Publisher: ${data['publisher']['title']}',
                        style: GoogleFonts.openSans(fontSize: 13, color: Colors.grey[800]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Published Date: ${data['published date']}',
                        style: GoogleFonts.openSans(fontSize: 13, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: (){
                  _launchURL(data['url']);
                }, icon: Icon(CupertinoIcons.arrowshape_turn_up_right_circle, size:28,))
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildCustomCardSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Expanded(
            //   child: Container(
            //     height: 20,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: 24),
              Container(
                height: 20,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: 12),
              Container(
                height: 20,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



}
