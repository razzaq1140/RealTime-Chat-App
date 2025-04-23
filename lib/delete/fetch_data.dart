import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FetchDataPage extends StatefulWidget {
  const FetchDataPage({super.key});

  @override
  State<FetchDataPage> createState() => _FetchDataPageState();
}

class _FetchDataPageState extends State<FetchDataPage> {
  final _searchController = TextEditingController();
  List allResults = [];
  List _resultList = [];

  getClientSteam() async {
    var data =
        await FirebaseFirestore.instance
            .collection('parentColl')
            .doc('parentDocId')
            .collection('nestedColl')
            .orderBy('name')
            .get();
    setState(() {
      allResults = data.docs;
    });
    searchResultList();
  }

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  _onSearchChanged() {
    if (kDebugMode) {
      print(_searchController.text);
    }
    searchResultList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getClientSteam();
    super.didChangeDependencies();
  }

  void searchResultList() {
    List showResult = [];

    if (_searchController.text.isNotEmpty) {
      for (var clientSnapShot in allResults) {
        var name = clientSnapShot["name"].toString().toLowerCase();
        if (name.contains(_searchController.text.toLowerCase())) {
          showResult.add(clientSnapShot);
        }
      }
    } else {
      showResult = List.from(allResults);
    }

    setState(() {
      _resultList = showResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Fetch Data', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    searchResultList();
                    setState(() {});
                  },
                ),
              ),
            ),
            SizedBox(height: 15),
            _resultList.isEmpty
                ? (_searchController.text.isNotEmpty
                    ? Center(child: Text('Data is not found'))
                    : Center(child: CircularProgressIndicator()))
                : ListView.builder(
                  itemCount: _resultList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final data = _resultList[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text("Name: ${data['name']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Age: ${data['age']}"),
                            Text("Class: ${data['class']}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
