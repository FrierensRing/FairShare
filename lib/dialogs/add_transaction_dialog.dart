// dialogs/add_transaction_dialog.dart - Dialog for adding a new transaction
import 'package:fairshare/models/glass_panel.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class AddTransactionDialog extends StatefulWidget {
  final List<String> userNames;
  final Function(Transaction) onTransactionAdded;

  const AddTransactionDialog({
    Key? key,
    required this.userNames,
    required this.onTransactionAdded,
  }) : super(key: key);

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();

  // Static method to show the dialog
  static Future<void> show(
    BuildContext context,
    List<String> userNames,
    Function(Transaction) onTransactionAdded,
  ) async {
    if (userNames.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please add users first')));
      return;
    }

    return showDialog(
      context: context,
      builder:
          (context) => AddTransactionDialog(
            userNames: userNames,
            onTransactionAdded: onTransactionAdded,
          ),
    );
  }
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late String? selectedPayer;
  late Map<String, bool> selectedSplittersMap = {};
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize selected payer
    selectedPayer = widget.userNames.isNotEmpty ? widget.userNames[0] : null;

    // Initialize all users as not selected for split
    for (var user in widget.userNames) {
      selectedSplittersMap[user] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size to calculate appropriate dialog height
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Dialog(
      // Use Dialog instead of AlertDialog for more control
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: GlassContainer(
        child: Container(
          // Set a maximum height to ensure it fits on screen with keyboard
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.7, // 70% of screen height max
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Take only needed space
            children: [
              // Header - Always visible
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 40, color: Colors.amber),
                    SizedBox(height: 8),
                    Text(
                      'Record Transaction',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description field
                        Text(
                          'Description (optional):',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 5),
                        TextField(
                          controller: descriptionController,
                          cursorColor: Colors.grey,
                          maxLength: 15, // Limiting to 15 characters
                          decoration: InputDecoration(
                            hintText: 'Dining? Grocery?',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
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
                            counterText: '15 char max', // Custom counter text
                            counterStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8)
                            )
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 15),

                        // Who paid dropdown
                        Text(
                          'Who paid?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButton<String>(
                            dropdownColor: Colors.grey,
                            iconEnabledColor: Colors.white,
                            value: selectedPayer,
                            isExpanded: true,
                            underline: SizedBox(),
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  selectedPayer = value;
                                });
                              }
                            },
                            items:
                                widget.userNames.map<DropdownMenuItem<String>>((
                                  String user,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: user,
                                    child: Text(
                                      user,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                        SizedBox(height: 15),

                        // Who should split
                        Text(
                          'Split between:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: widget.userNames.length,
                            itemBuilder: (context, index) {
                              final user = widget.userNames[index];
                              final isSelected =
                                  selectedSplittersMap[user] ?? false;

                              return Theme(
                                data: Theme.of(context).copyWith(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                ),
                                child: CheckboxListTile(
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  checkColor: Colors.amber,
                                  activeColor: Colors.white,
                                  title: Text(
                                    user,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      selectedSplittersMap[user] =
                                          value ?? false;
                                    });
                                  },
                                  dense: true, // More compact layout
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 15),

                        // Amount field
                        Text(
                          'Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 5),
                        TextField(
                          controller: amountController,
                          cursorColor: Colors.grey,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter amount',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
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
                            prefixIcon: Icon(
                              Icons.attach_money,
                              color: Colors.green.withOpacity(0.8),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // Action buttons - Always at the bottom
              GlassContainer(
                topLeft: 0,
                topRight: 0,
                fromGradient: 0.4,
                toGradient: 0.3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () {
                          _saveTransaction(context);
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction(BuildContext context) {
    // Get list of selected users for splitting
    List<String> selectedSplitters =
        selectedSplittersMap.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    if (selectedPayer != null &&
        selectedSplitters.isNotEmpty &&
        amountController.text.isNotEmpty) {
      try {
        double amount = double.parse(amountController.text);

        // Create the transaction
        Transaction newTransaction = Transaction(
          payerId: selectedPayer!,
          splitBetween: List.from(selectedSplitters),
          amount: amount,
          description: descriptionController.text.trim(),
        );

        // Pass the transaction back
        widget.onTransactionAdded(newTransaction);
        Navigator.pop(context);

        // Show success message with calculated split
        double perPersonAmount = amount / selectedSplitters.length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transaction recorded: ${selectedPayer} paid \$${amount.toStringAsFixed(2)}. ' +
                  'Each person owes \$${perPersonAmount.toStringAsFixed(2)}',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enter a valid amount')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }
}
