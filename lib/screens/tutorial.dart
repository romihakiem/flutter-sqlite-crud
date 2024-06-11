import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/tutorial.dart';
import '../services/database.dart';

class TutorialView extends StatefulWidget {
  final int? id;

  const TutorialView({super.key, this.id});

  @override
  State<TutorialView> createState() => _TutorialViewState();
}

class _TutorialViewState extends State<TutorialView> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  late TutorialModel _item;
  bool _isNew = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _refresh();
  }

  @override
  void dispose() {
    _db.close();

    super.dispose();
  }

  void _refresh() {
    if (widget.id == null) {
      setState(() => _isNew = true);
      return;
    }

    _db.readTutorial(widget.id!).then((val) {
      setState(() {
        _item = val;
        _titleController.text = _item.title!;
        _descController.text = _item.description!;
      });
    });
  }

  void _insert(TutorialModel val) {
    _db.insertTutorial(val).then((respond) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Item successfully added.'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context, {'reload': true});
    }).catchError((e) {
      if (kDebugMode) print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Item failed to save.'),
        backgroundColor: Colors.redAccent,
      ));
    });
  }

  void _update(TutorialModel val) {
    _db.updateTutorial(val).then((respond) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Item successfully updated.'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context, {'reload': true});
    }).catchError((e) {
      if (kDebugMode) print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Item failed to update.'),
        backgroundColor: Colors.redAccent,
      ));
    });
  }

  void _create() async {
    setState(() => _isLoading = true);

    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      TutorialModel val =
          TutorialModel(_titleController.text, _descController.text);

      if (_isNew) {
        _insert(val);
      } else {
        val.id = _item.id;
        _update(val);
      }
    }

    setState(() => _isLoading = false);
  }

  void _delete() {
    _db.deleteTutorial(_item.id!);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Item successfully deleted.'),
      backgroundColor: Colors.redAccent,
    ));
    Navigator.pop(context);
  }

  String? _validateTitle(String? val) {
    if (val == null || val.isEmpty) {
      return 'Enter a title.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0.0,
        title: Text(_isNew ? 'Add Tutorial' : 'Edit Tutorial'),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: '',
                      labelText: 'Title',
                    ),
                    validator: _validateTitle,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      hintText: '',
                      labelText: 'Description',
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _create,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text('Save'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Visibility(
                  visible: !_isNew,
                  child: ElevatedButton(
                    onPressed: _delete,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
