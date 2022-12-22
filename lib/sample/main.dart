import 'package:flutter/material.dart';
import 'package:sqflites/sample/sqlhelper.dart';

void main() {
  runApp(MaterialApp( home:sqflites()));
}

class sqflites extends StatefulWidget{
  @override
  State<sqflites> createState()=> _sqfState();
}

class _sqfState extends State<sqflites>{
  List<Map<String,dynamic>> data=[];
  bool isloading=true;

  void loaddata() async{
    final datas = await sqlHelper.getItems();
    setState(() {
      data=datas;
      isloading=false;
    });
  }
  void initState() {
    super.initState();
    loaddata(); // Loading the diary when the app starts
  }

  final TextEditingController _title =TextEditingController();
  final TextEditingController _description =TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
      data.firstWhere((element) => element['id'] == id);
      _title.text       = existingJournal['title'];
      _description.text = existingJournal['description'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            // this will prevent the soft keyboard from covering the text fields
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _description,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Save new journal
                  if (id == null) {
                    await _addItem();
                  }

                  if (id != null) {
                    await _updateItem(id);
                  }

                  // Clear the text fields
                  _title.text = '';
                  _description.text = '';

                  // Close the bottom sheet
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await sqlHelper.createItem(_title.text, _description.text);
    loaddata();
  }
  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await sqlHelper.updateItem(id, _title.text, _description.text);
    loaddata();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await sqlHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    loaddata();
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("sqflite"),),
      body: isloading? Center(
        child: CircularProgressIndicator(),
      ):ListView.builder(
        itemCount: data.length,
        itemBuilder: (context,index)=>Card(
          color: Colors.tealAccent,
          child: ListTile(
              title: Text(data[index]['title']),
              subtitle: Text(data[index]['description']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showForm(data[index]['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          _deleteItem(data[index]['id']),
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
      floatingActionButton:  FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
