import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FinanceCreationDialog extends StatefulWidget {
  final Function(String title, String description, double amount, DateTime deadline, DateTime createDate) onCreate;

  const FinanceCreationDialog ({
    super.key,
    required this.onCreate,
  });
  @override
  State<FinanceCreationDialog> createState() => _FinanceCreationDialogState();
}

class _FinanceCreationDialogState extends State<FinanceCreationDialog>{
  String title = '';
  String description = '';
  double amount = 0.0;
  late TextEditingController _dateController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  DateTime createDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    _dateController = TextEditingController(
      text: ""
    );
}

@override
Widget build(BuildContext context) {
  return Dialog(
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)),
    child: SingleChildScrollView(
     child: Padding(
      padding: const EdgeInsets.only( 
            bottom: 10,
            left: 20,
            right: 20,
            top: 20,
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
           Container(
            width: 300,
            height: 30,
            decoration: BoxDecoration( border: Border(bottom: BorderSide(width: 0.5, color: const Color.fromARGB(255, 166, 166, 166))),),
            child: Text(
            'Create Payment Reminder',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
      ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal:16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Enter Bill Name...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none
              ),
              onChanged: (value) => title = value,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal:16),
            height: 100,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(width: 1, color:Color.fromARGB(255, 213, 213, 213)),
            ),
            child:Align(
              alignment: Alignment.centerRight,
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Enter Description...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onChanged: (value) => description = value,
            ),
          ),
          ),
          const SizedBox(height: 10),

         Align(
            alignment: Alignment.center,
            child: Text('Enter Deadline', style: TextStyle(fontWeight: FontWeight.w200, fontSize: 13),),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal:15),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _dateController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'DD/MM/YY',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none
              ),
              readOnly: true,
              onTap: () => _showDatePicker(context),
            ),
          ),

          SizedBox(height: 15,),
          Align(
            alignment: Alignment.center,
            child: Text('Enter Cash Amount', style: TextStyle(fontWeight: FontWeight.w200, fontSize: 13),),
          ),
       
       Align( alignment: Alignment.center,
          child: Container(
            width: 200,
            padding: const EdgeInsets.only(left:0, right: 15),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 225, 225, 225),
              borderRadius: BorderRadius.circular(25),
            ),
              child: Row(
                children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            margin: EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey, width: 1)),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25), bottomLeft: Radius.circular(20))
            ),
           child: Text(
              'PHP',
              style: TextStyle(color: const Color.fromARGB(255, 89, 89, 89), fontSize: 13, fontWeight: FontWeight.w300),
                 ),
                     ),
            Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: '00.00',
                hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w200),
                border: InputBorder.none
              ),
              onChanged: (value) => amount = double.tryParse(value) ?? 0.0,
            ),
              ),
                ]
              ),

          ),
           ),
          const SizedBox(height:10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                                        fontWeight: FontWeight.w300
                  ),
                ),
              ),
              TextButton(
                onPressed: (){
                  if (title.isNotEmpty){
                    widget.onCreate(
                      title,
                      description,
                      amount,
                      DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      ),
                      createDate,
                    );
                    Navigator.pop(context);
                  }
                },child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Color.fromARGB(255, 176, 176, 176),
                    fontSize: 16,
                    fontWeight: FontWeight.w300
                  ),
                ),
              ),
            ]
          ),
         ]
        ),
      ),
    ),
  );
}

Future<void> _showDatePicker(BuildContext context) async{
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (context, child){
return Theme(
  data: Theme.of(context).copyWith(
    colorScheme: const ColorScheme.light(
      primary: Colors.green,
      onPrimary: Colors.white,
      onSurface: Colors.black,
    ),
    dialogBackgroundColor: Colors.white
  ),
  child: child!,
      );
    }
  );

  if (picked != null && picked != selectedDate){
    setState(() {
      selectedDate = picked;
      _dateController.text = '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}';
       });
     }
  }
  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }
}