# MI Broadcast Example

This example demonstrates the usage of the `mi_broadcast` package with a comprehensive Flutter application.

## Features Demonstrated

- **Basic Broadcasting**: Simple message broadcasting between components
- **Sticky Broadcasts**: Messages that are delivered to future receivers
- **Persistent Messages**: Messages that persist and can be retrieved later
- **Multiple Receivers**: Multiple receivers for the same event
- **Callback Support**: Two-way communication with callbacks
- **Context-based Registration**: Automatic cleanup with context

## Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the Example**
   ```bash
   flutter run
   ```

## How to Use the Example

The example app provides several buttons to demonstrate different features:

### Basic Operations
- **Register**: Registers a receiver for the 'demo_event'
- **Unregister**: Unregisters all receivers for the current context
- **Broadcast Message**: Sends a message to all registered receivers
- **Sticky Message**: Sends a sticky broadcast that future receivers will receive

### Advanced Features
- **Register with Response**: Registers a receiver that can send responses back
- **Broadcast with Callback**: Demonstrates two-way communication
- **Send Persistent Message**: Sends a message that persists
- **Get Persistent Value**: Retrieves a previously sent persistent message
- **Register Multiple Receivers**: Registers two receivers for the same event
- **Broadcast to Multiple**: Sends a message to all receivers
- **Send Sticky Catch-up**: Sends a sticky message, then registers a receiver to receive it

## Code Structure

The example is structured to show:
- How to register and unregister receivers
- Different types of broadcasts (regular, sticky, persistent)
- Context-based registration for automatic cleanup
- Multiple receiver scenarios
- Callback patterns for two-way communication

## Learning Points

1. **Memory Management**: Notice how the app uses context-based registration to prevent memory leaks
2. **Event Flow**: Observe how messages flow between different parts of the app
3. **Sticky Behavior**: See how sticky broadcasts are delivered to receivers that register after the broadcast
4. **Persistence**: Understand how persistent messages can be retrieved later

This example serves as a comprehensive guide for implementing broadcast messaging in your Flutter applications using the `mi_broadcast` package.
