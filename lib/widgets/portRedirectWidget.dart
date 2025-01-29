import 'package:flutter/material.dart';

class PortRedirectWidget extends StatefulWidget {
  const PortRedirectWidget({super.key});

  @override
  _PortRedirectWidgetState createState() => _PortRedirectWidgetState();
}

class _PortRedirectWidgetState extends State<PortRedirectWidget> {
  bool isRedirecting = false;
  String redirectPort = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(  // Aquí envuelves todo en un Scaffold
      appBar: AppBar(
        title: const Text('Port Redirect Widget'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text("Redirect Port 80"),
            value: isRedirecting,
            onChanged: (value) {
              setState(() {
                isRedirecting = value;
              });
            },
          ),
          if (isRedirecting)
            TextField(
              decoration: const InputDecoration(
                labelText: "Target Port",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  redirectPort = value;
                });
              },
            ),
        ],
      ),
    );
  }
}
