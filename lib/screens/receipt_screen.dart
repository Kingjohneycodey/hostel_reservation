import 'package:flutter/material.dart';
import '../models/receipt_model.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ReceiptScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Receipt")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset("asset/futologo.png", height: 80),
            const SizedBox(height: 20),

            Text(
              "Hostel Booking Receipt",
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const Divider(),

            buildRow("User ID", receipt.userId),
            buildRow("Student Name", receipt.studentName),
            buildRow("Hostel", receipt.hostelName),
            buildRow("Room Number", receipt.roomNumber),
            buildRow("Amount Paid", "₦${receipt.amountPaid}"),
            buildRow("Payment Date", receipt.paymentDate),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () => generatePdf(context),
              child: const Text("Print / Save as PDF"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Hostel Booking Receipt",
              style: pw.TextStyle(fontSize: 22),
            ),
            pw.SizedBox(height: 20),
            pw.Text("User ID: ${receipt.userId}"),
            pw.Text("Student Name: ${receipt.studentName}"),
            pw.Text("Hostel: ${receipt.hostelName}"),
            pw.Text("Room Number: ${receipt.roomNumber}"),
            pw.Text("Amount Paid: ₦${receipt.amountPaid}"),
            pw.Text("Payment Date: ${receipt.paymentDate}"),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
