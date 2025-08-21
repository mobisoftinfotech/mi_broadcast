import 'package:flutter_test/flutter_test.dart';
import 'package:mi_broadcast/mi_broadcast.dart';

void main() {
  group('MIBroadcast', () {
    late MIBroadcast broadcast;

    setUp(() {
      broadcast = MIBroadcast();
      broadcast.clearAll(); // Reset state before each test
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = MIBroadcast();
        final instance2 = MIBroadcast();
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Register and Unregister', () {
      test('should register receiver', () {
        bool received = false;
        String? receivedValue;

        broadcast.register('test_key', (value, callback) {
          received = true;
          receivedValue = value as String;
        });

        broadcast.broadcast('test_key', value: 'test_value');
        expect(received, isTrue);
        expect(receivedValue, equals('test_value'));
      });

      test('should register multiple receivers for same key', () {
        final receivedValues = <String>[];

        broadcast.register('test_key', (value, callback) {
          receivedValues.add(value as String);
        });

        broadcast.register('test_key', (value, callback) {
          receivedValues.add('${value}_modified');
        });

        broadcast.broadcast('test_key', value: 'test_value');
        expect(receivedValues, equals(['test_value', 'test_value_modified']));
      });

      test('should unregister by context', () {
        bool received = false;
        final context = Object();

        broadcast.register('test_key', (value, callback) {
          received = true;
        }, context: context);

        broadcast.unregister(context);
        broadcast.broadcast('test_key', value: 'test_value');
        expect(received, isFalse);
      });

      test('should remove specific receiver', () {
        final receivedValues = <String>[];
        void receiver1(dynamic value, void Function(dynamic result)? callback) {
          receivedValues.add('${value}_1');
        }

        void receiver2(dynamic value, void Function(dynamic result)? callback) {
          receivedValues.add('${value}_2');
        }

        broadcast.register('test_key', receiver1);
        broadcast.register('test_key', receiver2);

        broadcast.remove(receiver1, key: 'test_key');
        broadcast.broadcast('test_key', value: 'test_value');
        expect(receivedValues, equals(['test_value_2']));
      });
    });

    group('Broadcast', () {
      test('should broadcast to registered receivers', () {
        final receivedValues = <String>[];

        broadcast.register('test_key', (value, callback) {
          receivedValues.add(value as String);
        });

        broadcast.broadcast('test_key', value: 'test_value');
        expect(receivedValues, equals(['test_value']));
      });

      test('should not broadcast to unregistered receivers', () {
        bool received = false;
        final context = Object();

        broadcast.register('test_key', (value, callback) {
          received = true;
        }, context: context);

        broadcast.unregister(context);
        broadcast.broadcast('test_key', value: 'test_value');
        expect(received, isFalse);
      });

      test('should handle callback responses', () {
        String? callbackResult;

        broadcast.register('test_key', (value, callback) {
          callback?.call('processed_$value');
        });

        broadcast.broadcast(
          'test_key',
          value: 'test_value',
          callback: (result) {
            callbackResult = result as String;
          },
        );

        expect(callbackResult, equals('processed_test_value'));
      });

      test('should handle multiple callbacks', () {
        final callbackResults = <String>[];

        broadcast.register('test_key', (value, callback) {
          callback?.call('result1_$value');
        });

        broadcast.register('test_key', (value, callback) {
          callback?.call('result2_$value');
        });

        broadcast.broadcast(
          'test_key',
          value: 'test_value',
          callback: (result) {
            callbackResults.add(result as String);
          },
        );

        expect(callbackResults,
            equals(['result1_test_value', 'result2_test_value']));
      });
    });

    group('Sticky Broadcast', () {
      test('should deliver sticky message to future receivers', () {
        broadcast.stickyBroadcast('test_key', value: 'sticky_value');

        String? receivedValue;
        broadcast.register('test_key', (value, callback) {
          receivedValue = value as String;
        });

        expect(receivedValue, equals('sticky_value'));
      });

      test('should deliver sticky message to existing receivers', () {
        String? receivedValue;
        broadcast.register('test_key', (value, callback) {
          receivedValue = value as String;
        });

        broadcast.stickyBroadcast('test_key', value: 'sticky_value');
        expect(receivedValue, equals('sticky_value'));
      });

      test('should handle sticky broadcast with callback', () {
        String? callbackResult;
        broadcast.register('test_key', (value, callback) {
          callback?.call('sticky_processed_$value');
        });

        broadcast.stickyBroadcast(
          'test_key',
          value: 'sticky_value',
          callback: (result) {
            callbackResult = result as String;
          },
        );

        expect(callbackResult, equals('sticky_processed_sticky_value'));
      });
    });

    group('Persistent Messages', () {
      test('should store persistent messages', () {
        broadcast.broadcast('test_key',
            value: 'persistent_value', persistence: true);

        final value = MIBroadcast.value<String>('test_key');
        expect(value, equals('persistent_value'));
      });

      test('should deliver persistent message to new receivers', () {
        broadcast.broadcast('test_key',
            value: 'persistent_value', persistence: true);

        String? receivedValue;
        broadcast.register('test_key', (value, callback) {
          receivedValue = value as String;
        });

        expect(receivedValue, equals('persistent_value'));
      });

      test('should prioritize persistent over sticky messages', () {
        broadcast.stickyBroadcast('test_key', value: 'sticky_value');
        broadcast.broadcast('test_key',
            value: 'persistent_value', persistence: true);

        final value = MIBroadcast.value<String>('test_key');
        expect(value, equals('persistent_value'));
      });
    });

    group('Static value method', () {
      test('should return persistent value', () {
        broadcast.broadcast('test_key',
            value: 'persistent_value', persistence: true);
        final value = MIBroadcast.value<String>('test_key');
        expect(value, equals('persistent_value'));
      });

      test('should return sticky value', () {
        broadcast.stickyBroadcast('test_key', value: 'sticky_value');
        final value = MIBroadcast.value<String>('test_key');
        expect(value, equals('sticky_value'));
      });

      test('should return null for non-existent key', () {
        final value = MIBroadcast.value<String>('non_existent_key');
        expect(value, isNull);
      });

      test('should handle type casting', () {
        broadcast.broadcast('test_key', value: 42, persistence: true);
        final value = MIBroadcast.value<int>('test_key');
        expect(value, equals(42));
      });
    });

    group('Clear methods', () {
      test('should clear specific key', () {
        broadcast.register('test_key', (value, callback) {});
        broadcast.stickyBroadcast('test_key', value: 'sticky_value');
        broadcast.broadcast('test_key',
            value: 'persistent_value', persistence: true);

        broadcast.clear('test_key');

        final stickyValue = MIBroadcast.value<String>('test_key');
        final persistentValue = MIBroadcast.value<String>('test_key');
        expect(stickyValue, isNull);
        expect(persistentValue, isNull);
      });

      test('should clear all data', () {
        broadcast.register('key1', (value, callback) {});
        broadcast.register('key2', (value, callback) {});
        broadcast.stickyBroadcast('key1', value: 'sticky1');
        broadcast.broadcast('key2', value: 'persistent2', persistence: true);

        broadcast.clearAll();

        expect(MIBroadcast.value<String>('key1'), isNull);
        expect(MIBroadcast.value<String>('key2'), isNull);
      });
    });

    group('Context management', () {
      test('should track context entries', () {
        final context = Object();
        bool received = false;

        broadcast.register('test_key', (value, callback) {
          received = true;
        }, context: context);

        broadcast.broadcast('test_key', value: 'test_value');
        expect(received, isTrue);
      });

      test('should unregister all receivers for context', () {
        final context = Object();
        final receivedValues = <String>[];

        broadcast.register('key1', (value, callback) {
          receivedValues.add('${value}_1');
        }, context: context);

        broadcast.register('key2', (value, callback) {
          receivedValues.add('${value}_2');
        }, context: context);

        broadcast.unregister(context);
        broadcast.broadcast('key1', value: 'test1');
        broadcast.broadcast('key2', value: 'test2');

        expect(receivedValues, isEmpty);
      });
    });

    group('Edge cases', () {
      test('should handle null values', () {
        dynamic receivedValue;
        broadcast.register('test_key', (value, callback) {
          receivedValue = value;
        });

        broadcast.broadcast('test_key', value: null);
        expect(receivedValue, isNull);
      });

      test('should handle empty key', () {
        bool received = false;
        broadcast.register('', (value, callback) {
          received = true;
        });

        broadcast.broadcast('', value: 'test_value');
        expect(received, isTrue);
      });

      test('should handle complex objects', () {
        final testObject = {'key': 'value', 'number': 42};
        dynamic receivedValue;

        broadcast.register('test_key', (value, callback) {
          receivedValue = value;
        });

        broadcast.broadcast('test_key', value: testObject);
        expect(receivedValue, equals(testObject));
      });

      test('should handle concurrent registrations', () {
        final receivedValues = <String>[];

        // Register multiple receivers simultaneously
        for (int i = 0; i < 5; i++) {
          broadcast.register('test_key', (value, callback) {
            receivedValues.add('${value}_$i');
          });
        }

        broadcast.broadcast('test_key', value: 'test_value');
        expect(receivedValues.length, equals(5));
        expect(
            receivedValues.every((v) => v.startsWith('test_value_')), isTrue);
      });
    });
  });
}
