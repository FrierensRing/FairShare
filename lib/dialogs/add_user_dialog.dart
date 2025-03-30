// dialogs/add_user_dialog.dart - Dialog for adding a new user
import 'package:flutter/material.dart';

class AddUserDialog extends StatelessWidget {
  final Function(String) onUserAdded;

  const AddUserDialog({
    Key? key,
    required this.onUserAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    return AlertDialog(
      title: Column(
        children: [
          SizedBox(height: 20),
          Icon(Icons.people, size: 50),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Center(
              child: Text('Enter User Name', textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: TextField(
          controller: nameController,
          cursorColor: Colors.grey,
          decoration: InputDecoration(
            hintText: 'Enter name here',
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.orange,
                width: 2,
              ),
            ),
          ),
          autofocus: false,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel', style: TextStyle(color: Colors.orange)),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isNotEmpty) {
              onUserAdded(name);
              Navigator.pop(context);
            }
          },
          child: Text('Add User', style: TextStyle(color: Colors.orange)),
        ),
      ],
    );
  }

  // Static method to show the dialog
  static Future<void> show(BuildContext context, Function(String) onUserAdded) async {
    return showDialog(
      context: context,
      builder: (context) => AddUserDialog(onUserAdded: onUserAdded),
    );
  }
}