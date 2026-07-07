// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum StatusEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('pending')
  pending('pending'),
  @JsonValue('streaming')
  streaming('streaming'),
  @JsonValue('complete')
  complete('complete'),
  @JsonValue('error')
  error('error');

  final String? value;

  const StatusEnum(this.value);
}
