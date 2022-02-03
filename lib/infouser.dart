import 'dart:convert';
//import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'check.dart';
import 'counter.dart';
import 'user_id.dart';

// ignore: use_key_in_widget_constructors
class InfoUser extends StatelessWidget {
  late final UserID uid;

  @override
  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context)!.settings;
    uid = settings.arguments as UserID;

    // checklist.
    //if (id == checklist){}
    return Scaffold(
      drawer: const Drooo(),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.navigate_before),
            tooltip: 'Go to the next page',
            onPressed: () => Navigator.pop(context),
          ),
        ],
        title: const Text('Список User'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                  'https://randomuser.me/api/portraits/med/men/${uid.id}.jpg'),
              //    FlutterLogo(size: 100,),
            ),
            Text('Имя: ${uid.name}'),
            Text('Логин: ${uid.username}'),
            Text('Почта: ${uid.email}'),
            Text('Телефон: ${uid.phone}'),
            Text(
                'Адрес: индэкс:${uid.zipcode} г.${uid.city}, ул. ${uid.street}, ст.${uid.suite}, '),
            // Text('координаты: ${uid.lat}'),
            Text('website: ${uid.website}'),
            Text('Место работы: ${uid.cname}'),
            Text('Лозунг компании: ${uid.catchPhrase}'),
            Text('Сфера деятельности: ${uid.bs}'),
            const Text('Поставленные задачи:'),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: CheksID('${uid.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheksID extends StatefulWidget {
  final String _id;
  const CheksID(this._id, {Key? key}) : super(key: key);
  @override
  _CheksIDState createState() => _CheksIDState();
}

class _CheksIDState extends State<CheksID> {
  late Future<List<Check>> checklist;
  @override
  void initState() {
    super.initState();
    String id = widget._id;
    checklist = getCheckList(id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Check>>(
      future: checklist,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var fix = snapshot.data![index].completed as bool;
              return Card(
                color: fix ? Colors.green[50] : Colors.red[50],
                child: ListTile(
                  title: Text(
                      'Поставленная задача: ${snapshot.data![index].title}'),
                  subtitle: Row(
                    children: [
                      const Text('Отметка о выполнении ➾ '),
                      Checkbox(value: fix, onChanged: null)
                    ],
                  ),
                  leading: Text('№: ${index + 1}'),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<List<Check>> getCheckList(String id) async {
    List<Check> prodList = [];
    String url = 'https://jsonplaceholder.typicode.com/todos?userId=$id';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonList = jsonDecode(response.body);
      for (var prod in jsonList) {
        prodList.add(Check.fromJson(prod));
      }
      return prodList;
    } else {
      throw Exception('Error: ${response.reasonPhrase}');
    }
  }
}
