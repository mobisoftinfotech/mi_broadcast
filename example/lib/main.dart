import 'package:flutter/material.dart';
import 'package:mi_broadcast/mi_broadcast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'MI Broadcast Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _receivedMessage;
  bool _multiARegistered = false;
  bool _multiBRegistered = false;
  bool _responseRegistered = false;

  void _receiver(dynamic value, void Function(dynamic result)? callback) {
    setState(() {
      _receivedMessage = 'Received: \n$value';
    });
    callback?.call('Message processed');
  }

  void _receiverWithResponse(
    dynamic value,
    void Function(dynamic result)? callback,
  ) {
    setState(() {
      _receivedMessage = 'Received (with response): $value';
    });
    callback?.call('Receiver processed: $value');
  }

  void _receiverA(dynamic value, void Function(dynamic result)? callback) {
    debugPrint('_receiverA');
    setState(() {
      _receivedMessage = 'Receiver A got: $value';
    });
  }

  void _receiverB(dynamic value, void Function(dynamic result)? callback) {
    debugPrint('_receiverB');
    setState(() {
      _receivedMessage = 'Receiver B got: $value';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_receivedMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_receivedMessage!),
                ),
              ElevatedButton(
                onPressed: () {
                  MIBroadcast().register(
                    'demo_event',
                    _receiver,
                    context: this,
                  );
                  setState(() {
                    _receivedMessage = 'Receiver registered!';
                  });
                },
                child: Text('Register'),
              ),
              ElevatedButton(
                onPressed: () {
                  MIBroadcast().unregister(this);
                  setState(() {
                    _receivedMessage = 'Receiver unregistered!';
                    _multiARegistered = false;
                    _multiBRegistered = false;
                    _responseRegistered = false;
                  });
                },
                child: Text('Unregister'),
              ),
              ElevatedButton(
                onPressed: () {
                  MIBroadcast().broadcast(
                    'demo_event',
                    value: 'Hello from Broadcast!',
                    callback: (result) {
                      setState(() {
                        _receivedMessage = 'Broadcast callback: $result';
                      });
                    },
                  );
                },
                child: Text('Broadcast Message'),
              ),
              ElevatedButton(
                onPressed: () {
                  MIBroadcast().stickyBroadcast(
                    'demo_event',
                    value: 'Hello from Sticky!',
                    callback: (result) {
                      setState(() {
                        _receivedMessage = 'Sticky callback: $result';
                      });
                    },
                  );
                },
                child: Text('Sticky Message'),
              ),
              const Divider(height: 32),
              ElevatedButton(
                onPressed: _responseRegistered
                    ? null
                    : () {
                        MIBroadcast().register(
                          'response_event',
                          _receiverWithResponse,
                          context: this,
                        );
                        setState(() {
                          _receivedMessage =
                              'Receiver with response registered!';
                          _responseRegistered = true;
                        });
                      },
                child: Text('Register with Response'),
              ),
              ElevatedButton(
                onPressed: () {
                  MIBroadcast().broadcast(
                    'response_event',
                    value: 'Message needing response',
                    callback: (result) {
                      setState(() {
                        _receivedMessage = 'Broadcast got response: $result';
                      });
                    },
                  );
                },
                child: Text('Broadcast with Callback'),
              ),
              const Divider(height: 32),
              ElevatedButton(
                onPressed: () {
                  MIBroadcast().broadcast(
                    'persistent_event',
                    value: 'Persistent Data',
                    persistence: true,
                  );
                  setState(() {
                    _receivedMessage = 'Persistent message sent!';
                  });
                },
                child: Text('Send Persistent Message'),
              ),
              ElevatedButton(
                onPressed: () {
                  final value = MIBroadcast.value<String>('persistent_event');
                  setState(() {
                    _receivedMessage = 'Persistent value: $value';
                  });
                },
                child: Text('Get Persistent Value'),
              ),
              const Divider(height: 32),
              ElevatedButton(
                onPressed: _multiARegistered && _multiBRegistered
                    ? null
                    : () {
                        MIBroadcast().register(
                          'multi_event',
                          _receiverA,
                          context: this,
                        );
                        MIBroadcast().register(
                          'multi_event',
                          _receiverB,
                          context: this,
                        );
                        setState(() {
                          _receivedMessage = 'Two receivers registered!';
                          _multiARegistered = true;
                          _multiBRegistered = true;
                        });
                      },
                child: Text('Register Multiple Receivers'),
              ),
              ElevatedButton(
                onPressed: () {
                  MIBroadcast().broadcast(
                    'multi_event',
                    value: 'Hello to all!',
                  );
                },
                child: Text('Broadcast to Multiple'),
              ),
              const Divider(height: 32),
              ElevatedButton(
                onPressed: () {
                  MIBroadcast().stickyBroadcast(
                    'sticky_catchup',
                    value: 'Sticky catch-up!',
                  );
                  setState(() {
                    _receivedMessage = 'Sticky catch-up message sent!';
                  });
                },
                child: Text('Send Sticky Catch-up'),
              ),
              ElevatedButton(
                onPressed: () {
                  MIBroadcast().register('sticky_catchup', (value, callback) {
                    setState(() {
                      _receivedMessage = 'Sticky catch-up received: $value';
                    });
                  }, context: this);
                },
                child: Text('Register for Sticky Catch-up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
