import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';

class Horario extends StatefulWidget {
  const Horario({super.key});

  @override
  State<Horario> createState() => _HorarioState();
}

class _HorarioState extends State<Horario> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Horario',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            ElevatedButton(
              onPressed: () async {
                // Obtén la URL del PDF desde Firestore
                DocumentSnapshot documentSnapshot = await FirebaseFirestore
                    .instance
                    .collection('horarios')
                    .doc('choferes')
                    .get();
                String pdfUrl = documentSnapshot['fileUrl'];

                // Espera a que el PDF se cargue desde la URL
                final PDFDocument document = await PDFDocument.fromURL(pdfUrl);

                // Muestra el PDF en un visor
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFViewer(document: document),
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility, size: 18, color: Colors.teal),
                  SizedBox(width: 8), // Espacio entre el ícono y el texto
                  Text(
                    'Mostrar Horario',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}