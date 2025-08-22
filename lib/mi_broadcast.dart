/// A function type for broadcast receivers that handle messages.
///
/// [value] is the message data being broadcast.
/// [callback] is an optional callback function to send a response back to the broadcaster.
typedef MIBroadcastReceiver = void Function(
    dynamic value, void Function(dynamic result)? callback);

/// A singleton broadcast messaging system for Flutter applications.
///
/// This class provides a simple way to communicate between different parts of your Flutter app
/// using a publish-subscribe pattern. It supports sticky broadcasts, persistent messages,
/// and context-based registration for automatic cleanup.
class MIBroadcast {
  static final MIBroadcast _instance = MIBroadcast._internal();

  /// Creates a new instance of MIBroadcast.
  ///
  /// Returns the singleton instance of MIBroadcast.
  factory MIBroadcast() => _instance;

  /// Private constructor for singleton pattern.
  MIBroadcast._internal();

  // Map of key -> list of receivers (with optional context)
  final Map<String, List<_ReceiverEntry>> _receivers = {};
  // Map of key -> last value (for sticky/persistent messages)
  final Map<String, dynamic> _stickyMessages = {};
  final Map<String, dynamic> _persistentMessages = {};
  // Map of context -> list of (key, receiver)
  final Map<Object, List<_ContextEntry>> _contextMap = {};

  /// Register a receiver for a key, optionally with a context
  void register(String key, MIBroadcastReceiver receiver, {Object? context}) {
    final entry = _ReceiverEntry(receiver, context);
    _receivers.putIfAbsent(key, () => []).add(entry);
    if (context != null) {
      _contextMap
          .putIfAbsent(context, () => [])
          .add(_ContextEntry(key, receiver));
    }
    // Deliver sticky message if exists
    if (_stickyMessages.containsKey(key)) {
      receiver(_stickyMessages[key], null);
    }
    // Deliver persistent message if exists
    if (_persistentMessages.containsKey(key)) {
      receiver(_persistentMessages[key], null);
    }
  }

  /// Unregister all receivers for a context
  void unregister(Object context) {
    final entries = _contextMap.remove(context);
    if (entries != null) {
      for (final entry in entries) {
        remove(entry.receiver, key: entry.key, context: context);
      }
    }
  }

  /// Remove a specific receiver (optionally for a key/context)
  void remove(MIBroadcastReceiver receiver, {String? key, Object? context}) {
    if (key != null) {
      _receivers[key]?.removeWhere(
        (entry) =>
            entry.receiver == receiver &&
            (context == null || entry.context == context),
      );
    } else {
      for (final entries in _receivers.values) {
        entries.removeWhere(
          (entry) =>
              entry.receiver == receiver &&
              (context == null || entry.context == context),
        );
      }
    }
  }

  /// Broadcast a message to all receivers for a key
  void broadcast(
    String key, {
    dynamic value,
    void Function(dynamic result)? callback,
    bool persistence = false,
  }) {
    if (persistence) {
      _persistentMessages[key] = value;
    }
    final receivers = _receivers[key];
    if (receivers != null && receivers.isNotEmpty) {
      for (final entry in List<_ReceiverEntry>.from(receivers)) {
        entry.receiver(value, callback);
      }
    }
  }

  /// Send a sticky broadcast (delivered to future receivers)
  void stickyBroadcast(
    String key, {
    dynamic value,
    void Function(dynamic result)? callback,
    bool persistence = false,
  }) {
    _stickyMessages[key] = value;
    broadcast(key, value: value, callback: callback, persistence: persistence);
  }

  /// Get the last value for a key (persistent or sticky)
  static T? value<T>(String key) {
    final instance = MIBroadcast();
    if (instance._persistentMessages.containsKey(key)) {
      return instance._persistentMessages[key] as T?;
    }
    if (instance._stickyMessages.containsKey(key)) {
      return instance._stickyMessages[key] as T?;
    }
    return null;
  }

  /// Remove all receivers, sticky broadcasts and _persistentMessages for a key
  void clear(String key) {
    if (_receivers.containsKey(key)) {
      _receivers.remove(key);
    }
    if (_stickyMessages.containsKey(key)) {
      _stickyMessages.remove(key);
    }
    if (_persistentMessages.containsKey(key)) {
      _persistentMessages.remove(key);
    }
  }

  /// Remove all receivers and all sticky broadcasts
  void clearAll() {
    _receivers.clear();
    _stickyMessages.clear();
    _persistentMessages.clear();
    _contextMap.clear();
  }
}

class _ReceiverEntry {
  final MIBroadcastReceiver receiver;
  final Object? context;
  _ReceiverEntry(this.receiver, this.context);
}

class _ContextEntry {
  final String key;
  final MIBroadcastReceiver receiver;
  _ContextEntry(this.key, this.receiver);
}
