import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Service untuk membuat invoice dalam bentuk PDF atau TXT.
// Digunakan saat user ingin menyimpan atau membagikan rincian order.
class PdfService {
  /// Generate PDF order details dan langsung membuka dialog share/print.
  /// Parameter: informasi ringkasan order (nama produk, material, harga, dsb).
  static Future<void> generateOrderPdf({
    required String productName,
    required String materialName,
    required double quantity,
    required double basePrice,
    required double materialPrice,
    required double totalPrice,
    required String customerName,
    required String customerPhone,
    required String? notes,
    List<String>? filePaths,
  }) async {
    final pdf = pw.Document();

    // Format tanggal
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    final orderDate = dateFormat.format(now);
    
    // Generate order number
    final orderNumber = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 10000}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'RF DIGITAL PRINTING',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Invoice Pemesanan',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          orderNumber,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          orderDate,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Customer Information
              pw.Text(
                'INFORMASI PELANGGAN',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Nama', customerName),
                    pw.SizedBox(height: 8),
                    _buildInfoRow('No. Telepon', customerPhone),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Order Details
              pw.Text(
                'DETAIL PESANAN',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Table Header
              pw.Container(
                color: PdfColors.grey200,
                padding: const pw.EdgeInsets.all(10),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'Item',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Qty',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Harga',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Product Row
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            productName,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Material: $materialName',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        '${quantity.toStringAsFixed(0)} m',
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        _formatCurrency(totalPrice),
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Price Breakdown
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildPriceRow('Harga Produk', _formatCurrency(basePrice)),
                    pw.SizedBox(height: 8),
                    _buildPriceRow(
                      'Harga Material ($materialName)',
                      _formatCurrency(materialPrice),
                    ),
                    pw.SizedBox(height: 8),
                    _buildPriceRow(
                      'Kuantitas',
                      '${quantity.toStringAsFixed(0)} m',
                    ),
                    pw.Divider(thickness: 2),
                    _buildPriceRow(
                      'TOTAL',
                      _formatCurrency(totalPrice),
                      isBold: true,
                      isLarge: true,
                    ),
                  ],
                ),
              ),

              if (notes != null && notes.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'CATATAN',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(notes),
                ),
              ],

              if (filePaths != null && filePaths.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'FILE DESIGN',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: filePaths
                        .map((path) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 4),
                              child: pw.Text('• $path'),
                            ))
                        .toList(),
                  ),
                ),
              ],

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RF Digital Printing',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'WA: 0856-6420-2185',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        'www.rnr.tugas1.id',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Terima kasih atas pesanan Anda!',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save or share PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Generate TXT order details
  static Future<void> generateOrderTxt({
    required String productName,
    required String materialName,
    required double quantity,
    required double basePrice,
    required double materialPrice,
    required double totalPrice,
    required String customerName,
    required String customerPhone,
    required String? notes,
    List<String>? filePaths,
  }) async {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    final orderDate = dateFormat.format(now);
    final orderNumber = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 10000}';

    final StringBuffer buffer = StringBuffer();
    
    buffer.writeln('=====================================');
    buffer.writeln('    RF DIGITAL PRINTING');
    buffer.writeln('    INVOICE PEMESANAN');
    buffer.writeln('=====================================');
    buffer.writeln();
    buffer.writeln('No. Invoice: $orderNumber');
    buffer.writeln('Tanggal    : $orderDate');
    buffer.writeln();
    buffer.writeln('-------------------------------------');
    buffer.writeln('INFORMASI PELANGGAN');
    buffer.writeln('-------------------------------------');
    buffer.writeln('Nama       : $customerName');
    buffer.writeln('No. Telp   : $customerPhone');
    buffer.writeln();
    buffer.writeln('-------------------------------------');
    buffer.writeln('DETAIL PESANAN');
    buffer.writeln('-------------------------------------');
    buffer.writeln('Produk     : $productName');
    buffer.writeln('Material   : $materialName');
    buffer.writeln('Kuantitas  : ${quantity.toStringAsFixed(0)} meter');
    buffer.writeln();
    buffer.writeln('Harga Produk  : ${_formatCurrency(basePrice)}');
    buffer.writeln('Harga Material: ${_formatCurrency(materialPrice)}');
    buffer.writeln('-------------------------------------');
    buffer.writeln('TOTAL BAYAR   : ${_formatCurrency(totalPrice)}');
    buffer.writeln('=====================================');
    
    if (notes != null && notes.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Catatan:');
      buffer.writeln(notes);
    }
    
    if (filePaths != null && filePaths.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('File Design:');
      for (final path in filePaths) {
        buffer.writeln('- $path');
      }
    }
    
    buffer.writeln();
    buffer.writeln('-------------------------------------');
    buffer.writeln('RF Digital Printing');
    buffer.writeln('WA: 0856-6420-2185');
    buffer.writeln('-------------------------------------');
    buffer.writeln('Terima kasih atas pesanan Anda!');

    // Convert to bytes
    final bytes = Uint8List.fromList(buffer.toString().codeUnits);
    
    // Share/download the TXT file
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'RF_Order_$orderNumber.txt',
    );
  }

  // Helper methods
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            style: const pw.TextStyle(color: PdfColors.grey700),
          ),
        ),
        pw.Text(': '),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    bool isLarge = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: isLarge ? 16 : 12,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: isLarge ? 16 : 12,
          ),
        ),
      ],
    );
  }

  static String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
