import 'package:flutter/material.dart';

import '../models/tutorial.dart';
import '../services/database.dart';
import 'tutorial.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _db = DatabaseService();
  final _searchController = TextEditingController();
  bool _isNotEmpty = false;
  List<TutorialModel> _lists = [];
  List<TutorialModel> _filtered = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _isNotEmpty = _searchController.text.isNotEmpty;
        if (_isNotEmpty) {
          _filtered = _lists.where((val) {
            return val.title!
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ||
                val.description!
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase());
          }).toList();
        } else {
          _filtered.clear();
        }
      });
    });

    _refresh();
  }

  @override
  void dispose() {
    _db.close();

    super.dispose();
  }

  void _refresh() {
    _db.getAllTutorial().then((val) {
      setState(() => _lists = val);
    });
  }

  void _detail({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TutorialView(id: id)),
    );
    _refresh();
  }

  void _delete({int? id}) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Permanently'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Are you sure to delete this item?'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                await _db.deleteTutorial(id!);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Item successfully deleted.'),
                  backgroundColor: Colors.redAccent,
                ));
                _refresh();
              },
              child: const Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0.0,
        title: const Text('Tutorials'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              if (_isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filtered.clear();
                    _refresh();
                  },
                ),
            ],
          ),
          Divider(color: Colors.purple.shade100),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: _lists.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: Text(
                              'No records to display',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              if (_isNotEmpty)
                                ..._filtered.map((val) {
                                  return buildCard(val);
                                })
                              else
                                ..._lists.map((val) {
                                  return buildCard(val);
                                }),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _detail,
        tooltip: 'Create Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildCard(TutorialModel val) {
    return GestureDetector(
      onTap: () => {},
      child: ListTile(
        title: Text(val.title ?? ''),
        subtitle: Text(val.description ?? ''),
        trailing: Wrap(
          children: [
            IconButton(
              onPressed: () => _detail(id: val.id),
              icon: const Icon(Icons.edit, color: Colors.purple),
            ),
            IconButton(
              onPressed: () => _delete(id: val.id),
              icon: const Icon(Icons.delete, color: Colors.redAccent),
            ),
          ],
        ),
        shape: Border(
          bottom: BorderSide(color: Colors.purple.shade100),
        ),
      ),
    );
  }
}
