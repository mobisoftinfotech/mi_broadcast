# mi_broadcast

A lightweight and efficient broadcast messaging system for Flutter applications. This package provides a simple way to communicate between different parts of your Flutter app using a publish-subscribe pattern.

**Author:** Prashant Telangi ([LinkedIn](https://www.linkedin.com/in/prashant-telangi-83816918/))

**[Mobisoft Infotech - App Development Company, Houston](http://mobisoftinfotech.com/)** 

![mi_broadcast](assets/logo.png)


## Features

- 🚀 **Simple API**: Easy-to-use broadcast messaging system
- 🔄 **Multiple Receivers**: Support for multiple receivers per event
- 📌 **Sticky Broadcasts**: Messages that are delivered to future receivers
- 💾 **Persistent Messages**: Store and retrieve messages that persist during the app session and can be accessed throughout the entire application lifecycle
- 🎯 **Context-based Registration**: Automatic cleanup with context-based registration
- ⚡ **Lightweight**: Minimal overhead with efficient memory management
- 🔒 **Type Safe**: Support for type-safe value retrieval

## Getting Started

### Installation

Add `mi_broadcast` to your `pubspec.yaml`:

```yaml
dependencies:
  mi_broadcast: ^0.0.2
```

### Import

```dart
import 'package:mi_broadcast/mi_broadcast.dart';
```

## Usage

### Basic Broadcast

```dart
// Register a receiver
MIBroadcast().register('user_login', (value, callback) {
  print('User logged in: $value');
  callback?.call('Login processed');
});

// Broadcast a message
MIBroadcast().broadcast('user_login', value: 'john_doe');
```

### Sticky Broadcasts

Sticky broadcasts are delivered to receivers that register after the broadcast is sent:

```dart
// Send a sticky broadcast
MIBroadcast().stickyBroadcast('app_config', value: {'theme': 'dark'});

// Later, register a receiver (will receive the sticky message immediately)
MIBroadcast().register('app_config', (value, callback) {
  print('Received config: $value');
});
```

### Persistent Messages

Persistent messages are stored during the app session and can be retrieved throughout the application lifecycle:

```dart
// Send a persistent message
MIBroadcast().broadcast('user_preferences', 
  value: {'language': 'en'}, 
  persistence: true
);

// Retrieve the persistent value
final prefs = MIBroadcast.value<Map<String, dynamic>>('user_preferences');
print('User language: ${prefs?['language']}');
```

### Context-based Registration

Use context-based registration for automatic cleanup:

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    // Register with context for automatic cleanup
    MIBroadcast().register('data_update', _handleDataUpdate, context: this);
  }

  void _handleDataUpdate(dynamic value, void Function(dynamic result)? callback) {
    setState(() {
      // Update UI with new data
    });
    callback?.call('Data processed');
  }

  @override
  void dispose() {
    // Automatically unregisters all receivers for this context
    MIBroadcast().unregister(this);
    super.dispose();
  }
}
```

### Multiple Receivers

Register multiple receivers for the same event:

```dart
// Register multiple receivers
MIBroadcast().register('data_changed', (value, callback) {
  print('UI updated with: $value');
});

MIBroadcast().register('data_changed', (value, callback) {
  print('Analytics logged: $value');
});

// All receivers will be notified
MIBroadcast().broadcast('data_changed', value: 'new_data');
```

### Callback Support

Receivers can provide callbacks for two-way communication:

```dart
MIBroadcast().register('process_data', (value, callback) {
  // Process the data
  final result = processData(value);
  // Send result back
  callback?.call(result);
});

MIBroadcast().broadcast('process_data', 
  value: 'raw_data',
  callback: (result) {
    print('Processing result: $result');
  }
);
```

## API Reference

### MIBroadcast

The main class for broadcast operations.

#### Methods

- `register(String key, MIBroadcastReceiver receiver, {Object? context})`
  - Register a receiver for a specific key
  - Optional context for automatic cleanup

- `unregister(Object context)`
  - Unregister all receivers for a specific context

- `remove(MIBroadcastReceiver receiver, {String? key, Object? context})`
  - Remove a specific receiver

- `broadcast(String key, {dynamic value, void Function(dynamic result)? callback, bool persistence = false})`
  - Broadcast a message to all registered receivers

- `stickyBroadcast(String key, {dynamic value, void Function(dynamic result)? callback, bool persistence = false})`
  - Send a sticky broadcast that will be delivered to future receivers

- `value<T>(String key)`
  - Retrieve the last persistent or sticky value for a key

- `clear(String key)`
  - Remove all receivers and messages for a specific key

- `clearAll()`
  - Remove all receivers and messages

## Examples

Check out the [example app](example/lib/main.dart) for a complete demonstration of all features.

## Additional Information

### Best Practices

1. **Use Context-based Registration**: Always use context-based registration in widgets to prevent memory leaks
2. **Clean Up**: Use `unregister()` in `dispose()` methods
3. **Type Safety**: Use `MIBroadcast.value<T>()` for type-safe value retrieval
4. **Event Naming**: Use descriptive event names (e.g., 'user_login', 'data_updated')

### Performance Considerations

- The package uses a singleton pattern for efficient memory usage
- Receivers are stored in memory, so avoid registering too many receivers
- Use `clear()` or `clearAll()` when appropriate to free memory

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

> **Note:** This library is created taking inspiration from [fbroadcast](https://pub.dev/packages/fbroadcast) package.
