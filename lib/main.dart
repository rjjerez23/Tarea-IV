// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:math';


void main() {
  runApp(const LoanCalculatorApp());
}

class LoanCalculatorApp extends StatelessWidget {
  const LoanCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Préstamos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoanCalculator(),
    );
  }
}

class LoanCalculator extends StatefulWidget {
  const LoanCalculator({super.key});

  @override
  _LoanCalculatorState createState() => _LoanCalculatorState();
}

class _LoanCalculatorState extends State<LoanCalculator> {
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _monthsController = TextEditingController();

  List<Map<String, dynamic>> amortizationTable = [];
  double monthlyPayment = 0.0;

  void calculateLoan() {
    final double loanAmount = double.tryParse(_loanAmountController.text) ?? 0.0;
    final double annualInterestRate = double.tryParse(_interestRateController.text) ?? 0.0;
    final int months = int.tryParse(_monthsController.text) ?? 0;

    if (loanAmount > 0 && annualInterestRate > 0 && months > 0) {
      final double monthlyInterestRate = annualInterestRate / 12 / 100;
      monthlyPayment = (loanAmount * monthlyInterestRate) /
    (1 - pow(1 + monthlyInterestRate, -months));

      double remainingBalance = loanAmount;
      amortizationTable.clear();

      for (int i = 1; i <= months; i++) {
        final double interestPayment = remainingBalance * monthlyInterestRate;
        final double principalPayment = monthlyPayment - interestPayment;
        remainingBalance -= principalPayment;

        amortizationTable.add({
          'month': i,
          'payment': monthlyPayment,
          'principal': principalPayment,
          'interest': interestPayment,
          'balance': remainingBalance < 0 ? 0 : remainingBalance,
        });
      }
    } else {
      amortizationTable.clear();
      monthlyPayment = 0.0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de Préstamos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _loanAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monto del préstamo'),
            ),
            TextField(
              controller: _interestRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tasa de interés anual (%)'),
            ),
            TextField(
              controller: _monthsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad de meses'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: calculateLoan,
              child: const Text('Calcular'),
            ),
            const SizedBox(height: 16),
            if (monthlyPayment > 0)
              Text(
                'Pago mensual: ${monthlyPayment.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 16),
            if (amortizationTable.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: amortizationTable.length,
                  itemBuilder: (context, index) {
                    final row = amortizationTable[index];
                    return ListTile(
                      title: Text('Mes ${row['month']}'),
                      subtitle: Text(
                          'Pago: ${row['payment'].toStringAsFixed(2)} | Principal: ${row['principal'].toStringAsFixed(2)} | Interés: ${row['interest'].toStringAsFixed(2)} | Saldo: ${row['balance'].toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
