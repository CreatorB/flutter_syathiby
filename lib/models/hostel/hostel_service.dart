import 'package:dio/dio.dart';
import 'package:syathiby/models/hostel/food.dart';
import 'package:syathiby/models/hostel/hostel.dart';
import 'package:retrofit/retrofit.dart';

import '../staff/kinerja.dart';

part 'hostel_service.g.dart';

@RestApi() // Ubah URL sesuai kebutuhan Anda
abstract class AsramaRestInterface {
  factory AsramaRestInterface(Dio dio, {String baseUrl}) = _AsramaRestInterface;

  @GET("asrama/list.php")
  Future<List<Asrama>> get(
    @Query("key") String key,
    @Query("id") String id,
  );

  @GET("kelas/listkelas.php")
  Future<List<Asrama>> getKelas(
    @Query("key") String key,
    @Query("id") String id,
    @Query("id_jenis_asrama") String idJenisAsrama,
  );

  @GET("kelas/listjadwalkelas.php")
  Future<List<Asrama>> getDataKelas(
    @Query("key") String key,
    @Query("id_jenis_asrama") String idJenisAsrama,
  );

  @GET("kelas/listpresensi.php")
  Future<List<Asrama>> getDataPresenceList(
      @Query("key") String key,
      @Query("awal") String startDate,
      @Query("akhir") String endDate,
      @Query("divisi") String division,
      );

  @GET("attendance/listpresensi.php")
  Future<List<Kinerja>> getPresenceFilter(
      @Query("key") String key,
      @Query("awal") String startDate,
      @Query("akhir") String endDate,
      @Query("id") String id,
      @Query("value") String value,
      );

  @GET("attendance/listizin.php")
  Future<List<Kinerja>> getPermitAttendance(
      @Query("key") String key,
      @Query("awal") String startDate,
      @Query("akhir") String endDate,
      @Query("id") String id,
      );

  @GET("attendance/listpresensigroup.php")
  Future<List<Kinerja>> getPresenceGroup(
      @Query("key") String key,
      @Query("awal") String startDate,
      @Query("akhir") String endDate,
      @Query("id") String id,
      );


  @GET("kelas/listgedung.php")
  Future<List<Asrama>> getGedung(
    @Query("key") String key,
    @Query("id") String id,
  );

  @GET("kelas/listgedungasrama.php")
  Future<List<Asrama>> getGedungAsrama(
    @Query("key") String key,
  );

  @GET("kelas/listgedungpresensi.php")
  Future<List<Asrama>> getGedungPresensi(
    @Query("key") String key,
  );

  @GET("kelas/listgedungkelas.php")
  Future<List<Asrama>> getGedungKelas(
    @Query("key") String key,
  );

  @GET("kelas/listgedungmakan.php")
  Future<List<Makan>> getGedungMakan(
    @Query("key") String key,
    @Query("awal") String awal,
    @Query("akhir") String akhir,
  );
}
