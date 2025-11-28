import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     home: Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/img.png'),

                ),
                SizedBox(width: 20),
                Text(
                  'Matt Arnel V. Amparo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            Row(
              children: [
                Icon(Icons.email, color: Colors.blue, size: 30),
                SizedBox(width: 20,),
                Text('Email:', style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(width: 10,),
                Text('john@gmail.com'),
                ],
            ),
            SizedBox(height: 10,),
                        Row(
              children: [
                Icon(Icons.phone, color: Colors.green, size: 30),
                SizedBox(width: 20,),
                Text('Phone:', style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(width: 10,),
                Text('+63 963 946 6185'),
                ],
            ),
             SizedBox(height: 10,),
                        Row(
              children: [
                Icon(Icons.school, color: Colors.red, size: 30,),
                SizedBox(width: 20,),
                Text('School:', style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(width: 10,),
                Text('john@gmail.com'),
                ],
            ),
          ],
        )
      )


    ),

    );
    
  }
}
