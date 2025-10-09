import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/transaction/comission.dart';
import 'package:syathiby/models/transaction/detail_history.dart';
import 'package:syathiby/models/transaction/detail_job.dart';
import 'package:syathiby/models/transaction/detail_label.dart';
import 'package:syathiby/models/transaction/detail_payment.dart';
import 'package:syathiby/models/transaction/detail_spend.dart';
import 'package:syathiby/models/transaction/detail_transaction.dart';
import 'package:syathiby/models/transaction/detail_transfer.dart';
import 'package:syathiby/models/transaction/history_transaction.dart';
import 'package:syathiby/models/transaction/history_transfer.dart';
import 'package:syathiby/models/transaction/non_tunai.dart';
import 'package:syathiby/models/transaction/order.dart';
import 'package:syathiby/models/transaction/req_trans.dart';
import 'package:syathiby/models/transaction/request_add_order.dart';
import 'package:syathiby/models/transaction/request_kulakan.dart';
import 'package:syathiby/models/transaction/request_transaction.dart';
import 'package:syathiby/models/transaction/request_transfer.dart';
import 'package:syathiby/models/transaction/transaction.dart';
import 'package:syathiby/models/transaction/transfer.dart';
import 'package:retrofit/retrofit.dart';

part 'transaction_service.g.dart';

@RestApi()
abstract class TransactionService {
  factory TransactionService(Dio dio, {String baseUrl}) = _TransactionService;

  @GET('customer/transaction.php')
  Future<List<Transaction>> getCustomerTransactions(
    @Query('key') String key,
    @Query('id_customer') String id,
  );

  @GET('customer/debt.php')
  Future<List<Transaction>> getCustomerDebts(
    @Query('key') String key,
    @Query('id_customer') String id,
  );

  @GET('supplier/transaction.php')
  Future<List<Transaction>> getSupplierTransactions(
    @Query('key') String key,
    @Query('id_supplier') String id,
  );

  @GET('supplier/debt.php')
  Future<List<Transaction>> getSupplierDebts(
    @Query('key') String key,
    @Query('id_supplier') String id,
  );

  @GET('transaction/struck.php')
  Future<DetailTransaction> getDetailTransaction(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('pengadaan/detail.php')
  Future<DetailTransaction> getDetailPengadaan(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('permintaan/detail.php')
  Future<DetailTransaction> getDetailPermintaanObat(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('masak/detail.php')
  Future<DetailTransaction> getDetailMasak(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('transaction/strucktransfer.php')
  Future<DetailTransfer> getDetailTransfer(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('transaction/struckreturn.php')
  Future<DetailTransaction> getDetailTransactionReturn(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('transaction/detaillabel.php')
  Future<DetailLabel> getDetailLabel(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('transaction/strucksupplier.php')
  Future<DetailTransaction> getDetailTransactionSupplier(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('transaction/strucksupplierreturn.php')
  Future<DetailTransaction> getDetailTransactionReturnSupplier(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('transaction/cancelorder.php')
  Future<Message> deleteDetailTransaction(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @POST('sales/order.php')
  Future<Order> order(
    @Body() RequestTransaction request,
  );

  @POST('sales/orderreturn.php')
  Future<Order> orderReturn(
    @Body() RequestTransaction request,
  );

  @POST('label/insert.php')
  Future<Order> printLabel(
    @Body() RequestTransaction request,
  );

  @POST('sales/orderdirect.php')
  Future<Order> orderDirect(
    @Body() RequestTransaction request,
  );

  @POST('pengadaan/prosesspengadaan.php')
  Future<Order> processPengadaan(
    @Body() Map<String, dynamic> map,
  );

  @POST('permintaan/prosesspermintaan.php')
  Future<Order> processPermintaaanObat(
    @Body() Map<String, dynamic> map,
  );

  @POST('masak/prosess.php')
  Future<Order> processMasak(
    @Body() RequestTransaction request,
  );

  @POST('purchase/order.php')
  Future<Order> kulakan(
    @Body() RequestKulakan request,
  );

  @POST('purchase/transfer.php')
  Future<Order> transfer(
    @Body() RequestTransfer request,
  );

  @POST('sales/recipe.php')
  Future<Order> recipe(
    @Body() RequestTransaction request,
  );

  @POST('spending/insert.php')
  Future<Message> pengeluaran(
    @Body() Map<String, dynamic> request,
  );

  @GET('history/completetransactionlist.php')
  Future<List<HistoryTransaction>> historyTransaction(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
    @Query('status') String status,
  );

  @GET('pengadaan/datapengadaan.php')
  Future<List<HistoryTransaction>> historyPengadaan(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
    @Query('status') String status,
  );

  @GET('puasa/datapuasa.php')
  Future<List<HistoryTransaction>> historyPuasa(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
    @Query('status') String status,
  );

  @GET('pengadaan/listdatapengadaan.php')
  Future<List<Transaction>> dataPengadaan(
    @Query('key') String key,
  );

  @GET('permintaan/datappermintaan.php')
  Future<List<HistoryTransaction>> historyPengadaanObat(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
    @Query('status') String status,
  );

  @GET('masak/data.php')
  Future<List<HistoryTransaction>> historyMasak(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
    @Query('status') String? status,
  );

  @GET('history/historyjob.php')
  Future<List<DetailJob>> HistoryJob(
    @Query('key') String key,
    @Query('operator') String operator,
  );

  @GET('transaction/transferout.php')
  Future<List<HistoryTransfer>> getTransferOut(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
    @Query('status') String status,
  );

  @GET('transaction/transferin.php')
  Future<List<HistoryTransfer>> getTransferIn(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
    @Query('status') String status,
  );

  @GET('history/completetransactionlistreturn.php')
  Future<List<HistoryTransaction>> historyTransactionReturn(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
    @Query('status') String status,
  );

  @GET('network/commision.php')
  Future<List<Comission>> historyComission(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
    @Query('status') String status,
  );

  @POST('sales/salesdata.php')
  Future<Message> addSalesData(
    @Field('user') String user,
    @Field('no_invoice') String noInvoice,
    @Field('id_customer') String idCustomer,
    @Field('id_store') String idStore,
    @Field('payment') String payment,
    @Field('totalorder') String totalorder,
    @Field('totalprice') String totalprice,
    @Field('totalpay') String totalpay,
    @Field('changepay') String changepay,
    @Field('status') String status,
    @Field('due_date') String dueDate,
    @Field('tax') String tax,
    @Field('discount') String discount,
    @Field('service_charge') String serviceCharge,
    @Field('operator') String operator,
    @Field('location') String location,
    @Field('note') String note,
    @Field('date') String date,
  );

  @POST('spending/spendingdata.php')
  Future<Message> addSpendingData(
    @Field('user') String user,
    @Field('id_store') String idStore,
    @Field('no_invoice') String payment,
    @Field('date') String totalprice,
    @Field('totalnominal') String totalpay,
  );

  @POST('spending/spending.php')
  Future<Message> addSpending(
    @Field('name_spending') String user,
    @Field('user') String idStore,
    @Field('no_invoice') String payment,
    @Field('nominal') String totalprice,
    @Field('date') String totalpay,
  );

  @POST('sales/sales.php')
  Future<Message> addSales(
    @Field('user') String user,
    @Field('no_invoice') String noInvoice,
    @Field('id_customer') String idCustomer,
    @Field('id_store') String idStore,
    @Field('id_product') String payment,
    @Field('amount') String totalorder,
    @Field('totalprice') String totalprice,
    @Field('price') String totalpay,
    @Field('status') String status,
    @Field('note') String note,
    @Field('date') String date,
  );

  @POST('transaction/paydebtcustomers.php')
  Future<Message> payPiutang(
    @Field('key') String key,
    @Field('no_invoice') String id,
    @Field('totalpay') String bayar,
  );

  @POST('transaction/paydebtsupplier.php')
  Future<Message> payHutang(
    @Field('key') String key,
    @Field('no_invoice') String id,
    @Field('totalpay') String bayar,
  );

  @GET('history/searchpengadaan.php')
  Future<List<Transaction>> searchTransaction(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET('history/searchpermintaan.php')
  Future<List<Transaction>> searchTransactionObat(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET('history/searchmasak.php')
  Future<List<Transaction>> searchMasak(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET('pengadaan/searchpengadaan.php')
  Future<List<Transaction>> searchPengadaan(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET('history/searchtransferin.php')
  Future<List<Transfer>> searchTransactionIn(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET('history/searchtransferout.php')
  Future<List<Transfer>> searchTransactionOut(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET('history/searchtransactionreturn.php')
  Future<List<Transaction>> searchTransactionReturn(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET('transaction/cancelordersupplier.php')
  Future<Message> deleteSupplierDetailTransaction(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('pengadaan/confirm.php')
  Future<Message> aprovePengadaan(
    @Query('key') String key,
    @Query('no_invoice') String id,
    @Query('value') String data,
    @Query('alasan') String? alasan,
  );

  @GET('permintaan/confirm.php')
  Future<Message> aprovePermintaanObat(
    @Query('key') String key,
    @Query('no_invoice') String invoiceId,
    @Query('value') String data,
    @Query('alasan') String? alasan,
  );

  @GET('pengadaan/ubahharga.php')
  Future<Message> hargaPengadaan(
    @Query('key') String key,
    @Query('id_product') String idProduct,
    @Query('no_invoice') String noInvoice,
    @Query('price') String price,
  );

  @GET('sales/detailprice.php')
  Future<List<DetailPayment>> checkPayment(
    @Query('key') String key,
    @Query('totalprice') double totalharga,
    @Query('id_discount') String? idDiscount,
  );

  @GET('spending/history.php')
  Future<List<HistoryTransaction>> historySpend(
    @Query('key') String key,
    @Query('start_date') String awal,
    @Query('finish_date') String akhir,
  );

  @GET('history/searchexpenses.php')
  Future<List<Transaction>> searchSpend(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET('spending/detail.php')
  Future<DetailSpend> getDetailSpend(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('sales/link.php')
  Future<List<NonTunai>> getNonTunai(
    @Query('key') String key,
  );

  @POST('sales/addorder.php')
  Future<Order> addorder(
    @Body() RequestAddOrder request,
  );

  @GET('transaction/deleteorder.php')
  Future<Message> deleteAddTransaction(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('sales/deleteproduct.php')
  Future<Message> deleteProductItem(
    @Query('key') String key,
    @Query('no_invoice') String noInvoice,
    @Query('id_product') String id,
  );

  @GET('sales/additemproduct.php')
  Future<Message> plusProductItem(
    @Query('key') String key,
    @Query('no_invoice') String noInvoice,
    @Query('id_product') String id,
  );

  @GET('sales/cutitemproduct.php')
  Future<Message> minusProductItem(
    @Query('key') String key,
    @Query('no_invoice') String noInvoice,
    @Query('id_product') String id,
  );

  @POST('sales/splitorder.php')
  Future<Order> paySplit(
    @Body() ReqTrans request,
  );

  @GET('transaction/listordersuccsess.php')
  Future<List<HistoryTransaction>> getTransactionSuccessOrder(
    @Query('key') String key,
  );

  @GET('transaction/listorder.php')
  Future<List<HistoryTransaction>> getTransactionOrder(
    @Query('key') String key,
  );

  @GET('table/transactionsnotable.php')
  Future<List<Transaction>> getTransactionsNotable(
    @Query('key') String key,
  );

  @GET('table/transactions.php')
  Future<List<Transaction>> getTableTransactions(
    @Query('key') String key,
    @Query('id_table') String id,
  );

  @GET('transaction/finishorder.php')
  Future<Message> finishDetailTransaction(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('transaction/finishtransfer.php')
  Future<Message> finishTransfer(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @POST('sales/updateorder.php')
  Future<Order> payOrder(
    @Body() RequestTransaction request,
  );

  @GET('transaction/historystock.php')
  Future<List<DetailHistory>> getHistoryStock(
    @Query('key') String key,
    @Query('id_product') String idProduct,
  );

  @GET('transaction/historyjob.php')
  Future<List<DetailJob>> getHistoryJob(
    @Query('key') String key,
    @Query('no_invoice') String phoneNumber,
  );

  @POST('rawmaterial/order.php')
  Future<Order> orderraw(
    @Body() Map<String, dynamic> request,
  );

  @GET('rawmaterial/historystock.php')
  Future<List<DetailHistory>> getHistoryStockRawMaterial(
    @Query('key') String key,
    @Query('id') String idProduct,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
  );

  @GET('transaction/deletespend.php')
  Future<Message> deleteDetailSpend(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  // @POST('spending/insert.php')
  // Future<Order> add(
  //   @Body() Map<String, dynamic> requestSpending,
  // );

  @POST('spending/insert.php')
  @MultiPart()
  Future<Order> add(
    @Part(name: 'key') String key,
    @Part(name: 'date') String date,
    @Part(name: 'amount') double amount,
    @Part(name: 'data') Map<String, dynamic> data, {
    @Part(name: 'img') File? img,
  });
}
