import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CreateScreen extends StatefulWidget {
  final String token;

  const CreateScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  @override
  void initState() {
    getAll();
    super.initState();
  }

  final Dio dio = Dio();

  double total = 0.0;
  int i = 1;
  String message = '';
  List customerList = [];
  List storesList = [];
  List itemsList = [];
  TextEditingController customerController = TextEditingController();
  TextEditingController paymentTypeController = TextEditingController();
  TextEditingController itemController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController totalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AFAKY'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Form - Header:'),
              TextField(
                controller: customerController,
                decoration: const InputDecoration(labelText: 'Customer'),
              ),
              TextField(
                controller: paymentTypeController,
                decoration: const InputDecoration(labelText: 'Payment Type'),
              ),
              const Text('Payment Form - Details:'),
              TextField(
                controller: itemController,
                decoration: const InputDecoration(labelText: 'Item'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              ElevatedButton(
                onPressed: () {
                  double price = double.tryParse(priceController.text) ?? 0.0;
                  double quantity = double.tryParse(quantityController.text) ?? 0.0;
                  setState(() {
                    total = price * quantity;
                  });
                  createInvoice(total).then((_) {
                    customerController.clear();
                    paymentTypeController.clear();
                    itemController.clear();
                    quantityController.clear();
                    priceController.clear();
                  });
                  i++;
                },
                child: const Text('Add Invoice'),
              ),
              Center(
                child: Text(message),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getAll() async {
    const loginUrl = "https://back.afakyerp.com/API/PosForm/GetAll";

    try {
      final response = await dio.get(
        loginUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer ${widget.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      final responseData = response.data;

      if (responseData["status"] == 200) {
        log(responseData.toString());
        final data = responseData["data"][0];
        customerList = data["customerList"];
        storesList = data["storesList"];
        itemsList = data["itemsList"];
        debugPrint("get success");
      } else {
        debugPrint("Request failed with status ${responseData["status"]}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> createInvoice(
    double total,
  ) async {
    const addInvoiceUrl = "https://back.afakyerp.com/API/PosForm/Add";

    Map<String, dynamic> invoiceData = {
      "sceId": customerList[0]["id"],
      "invoiceType": 10,
      "currencyId": 1,
      "rate": 1,
      "total": total,
      "netTotal": total,
      "amountPaid": total,
      "remainingAmount": 0,
      "totalPayment": total,
      "invoiceDetails": [
        {
          "invoiceType": 10,
          "id": i + 1,
          "itemId": itemsList[0]["itemId"],
          "unitId": itemsList[0]["unitId"],
          "quantity": 1,
          "price": 1,
          "total": total,
          "totalAfterDiscount1": total,
          "totalAfterDiscount2": total,
          "totalAfterDiscount3": total,
          "netPrice": total,
          "description": "Test Invoice",
          "storeId": storesList[0]["storeId"],
        }

      ],
    };

    try {
      final response = await dio.post(
        addInvoiceUrl,
        data: jsonEncode(invoiceData),
        options: Options(
          headers: {
            "Authorization": "Bearer ${widget.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint("Invoice created successfully.");
        debugPrint(response.toString());
        debugPrint(i.toString());
        i=1;
        setState(() {
          message = response.data['message'];
        });
      } else {
        debugPrint("Failed to create the invoice.");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}
