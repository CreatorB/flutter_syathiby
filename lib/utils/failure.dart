import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.network() = NetworkFailure;

  const factory Failure.server(String message, String errorCode) =
      ServerFailure;

  const factory Failure.unexpected(String message) = UnexpectedFailure;
}
