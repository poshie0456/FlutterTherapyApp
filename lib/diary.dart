// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryEntry {
  String text;
  DateTime date;

  DiaryEntry({required this.text, required this.date});
}

class DiaryHomePage extends StatefulWidget {
  const DiaryHomePage({super.key});

  @override
  _DiaryHomePageState createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  List<DiaryEntry> entries = [];
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _editTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? entryStrings = prefs.getStringList('entries');
    if (entryStrings != null) {
      setState(() {
        entries = entryStrings.map((entryString) {
          List<String> parts = entryString.split('|');
          return DiaryEntry(
            text: parts[0],
            date: DateTime.parse(parts[1]),
          );
        }).toList();
      });
    }
  }

  Future<void> _saveEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> entryStrings = entries
        .map((entry) => '${entry.text}|${entry.date.toIso8601String()}')
        .toList();
    await prefs.setStringList('entries', entryStrings);
  }

  void _addEntry(String entry) {
    setState(() {
      entries.add(DiaryEntry(text: entry, date: DateTime.now()));
    });
    _saveEntries();
  }

  void _deleteEntry(int index) {
    setState(() {
      entries.removeAt(index);
    });
    _saveEntries();
  }

  void _editEntry(int index, String newText) {
    setState(() {
      entries[index].text = newText;
    });
    _saveEntries();
  }

  void _startEditing(int index) {
    _editTextController.text = entries[index].text;
    showDialog(
      context: context,
      builder: (context) {
        return AnimatedBuilder(
          animation: ModalRoute.of(context)!.animation!,
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity: ModalRoute.of(context)!.animation!.value,
              child: AlertDialog(
                backgroundColor: const Color(0xffAB72AC),
                title: const Text(
                  'Edit Entry',
                  style: TextStyle(color: Colors.white),
                ),
                content: TextField(
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  controller: _editTextController,
                  decoration: const InputDecoration(
                      hintText: 'Enter your edited entry',
                      hintStyle: TextStyle(color: Colors.white)),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _editEntry(index, _editTextController.text);
                      _editTextController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          Text(
            "Diary",
            style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.sizeOf(context).height * 0.02),
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    _startEditing(index);
                  },
                  title: Text(
                    entries[index].text,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    '${entries[index].date.day}/${entries[index].date.month}/${entries[index].date.year}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        onPressed: () => _deleteEntry(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AnimatedBuilder(
                animation: ModalRoute.of(context)!.animation!,
                builder: (BuildContext context, Widget? child) {
                  return Opacity(
                    opacity: ModalRoute.of(context)!.animation!.value,
                    child: AlertDialog(
                      backgroundColor: const Color(0xff4784B2),
                      title: const Text(
                        'New Entry',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: TextField(
                        style: const TextStyle(color: Colors.white),
                        maxLines: null,
                        controller: _textEditingController,
                        decoration: const InputDecoration(
                            hintText: 'Enter your entry',
                            hintStyle: TextStyle(color: Colors.white)),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _addEntry(_textEditingController.text);
                            _textEditingController.clear();
                            Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
