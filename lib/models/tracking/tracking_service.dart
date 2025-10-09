import 'package:dio/dio.dart';
import 'package:syathiby/models/tracking/tracking.dart';
import 'package:retrofit/retrofit.dart';

part 'tracking_service.g.dart';

@RestApi(baseUrl: 'tracking')
abstract class TrackingRestInterface {
  factory TrackingRestInterface(Dio dio, {String baseUrl}) =
      _TrackingRestInterface;

  @GET('tracking.php')
  Future<List<Tracking>> getTracking(
    @Query('key') String key,
  );
}
