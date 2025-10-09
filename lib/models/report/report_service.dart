import 'package:dio/dio.dart';
import 'package:syathiby/models/report/report_daily.dart';
import 'package:syathiby/models/report/report_laba_rugi.dart';
import 'package:syathiby/models/report/report_mutasi.dart';
import 'package:syathiby/models/report/report_penjualan.dart';
import 'package:syathiby/models/report/report_stock.dart';
import 'package:syathiby/models/report/report_transaksi.dart';
import 'package:syathiby/models/transaction/history_transaction.dart';
import 'package:syathiby/models/transaction/transaction.dart';
import 'package:retrofit/retrofit.dart';

part 'report_service.g.dart';

@RestApi(baseUrl: 'report/')
abstract class ReportRestInterface {
  factory ReportRestInterface(Dio dio, {String baseUrl}) = _ReportRestInterface;

  @GET('transaction.php')
  Future<List<ReportTransaksi>> transactions(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
  );

  @GET('searchtransaction.php')
  Future<List<ReportTransaksi>> searchTransactions(
    @Query('key') String key,
    @Query('search') String search,
  );

  @GET('sorttransaksi.php')
  Future<List<ReportTransaksi>> sortTransactions(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
  );

  @GET('labarugi.php')
  Future<ReportLabaRugi> labaRugi(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
  );

  @GET('mutasikas.php')
  Future<ReportMutasi> mutasi(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
  );

  @GET('stokproduct.php')
  Future<List<ReportStock>> stock(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
  );

  @GET('searchstock.php')
  Future<List<ReportStock>> searchStock(
    @Query('key') String key,
    @Query('search') String search,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
  );

  @GET('sortstockproduct.php')
  Future<List<ReportStock>> sortStock(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
  );

  @GET('sorthargastok.php')
  Future<List<ReportStock>> sortPriceStock(
    @Query('key') String key,
    @Query('tanggal_awal') String awal,
    @Query('tanggal_akhir') String akhir,
  );

  @GET('historikulakan.php')
  Future<List<HistoryTransaction>> kulakan(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
    @Query('status') String status,
  );

  @GET('carihistorikulakan.php')
  Future<List<Transaction>> searchKulakan(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET('sales.php')
  Future<ReportPenjualan> penjualan(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
    @Query('id_store') String? toko,
  );

  @GET('daily.php')
  Future<ReportDaily> daily(
    @Query('key') String key,
    @Query('first_date') String awal,
    @Query('last_date') String akhir,
    @Query('id_store') String? toko,
  );
}
