import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle_notifications,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Notificaciones',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
      ),
      body: ListView(
        children: const <Widget>[
          NotificationCard(
            message: 'Mantenimiento programado',
            iconColor: Colors.green,
          ),
          NotificationCard(
            message: 'Vehículo averiado',
            iconColor: Colors.red,
          ),
          NotificationCard(
            message: 'Vehículo averiado',
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String message;
  final Color iconColor;

  const NotificationCard({
    required this.message,
    required this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.notifications_sharp,
          color: iconColor,
        ),
        title: Text(message),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
