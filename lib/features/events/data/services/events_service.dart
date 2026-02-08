import 'package:dartz/dartz.dart';
import 'package:gearhead_br/core/network/api_client.dart';
import 'package:gearhead_br/core/network/api_endpoints.dart';
import 'package:gearhead_br/core/network/data_sources/base_data_source.dart';
import 'package:gearhead_br/core/network/models/api_error.dart';
import 'package:gearhead_br/features/events/data/models/event_model.dart';
import 'package:gearhead_br/features/events/domain/entities/event_entity.dart';

class EventsService extends BaseDataSource {
  EventsService(super.apiClient);

  Future<Either<ApiError, List<EventEntity>>> getEvents({
    String? type,
  }) async {
    final result = await executeListRequest<EventModel>(
      request: () => apiClient.get(
        ApiEndpoints.events,
        queryParameters: {
          if (type != null) 'type': type,
        },
      ),
      fromJson: (json) => EventModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((models) => models.map((model) => model.toEntity()).toList());
  }

  Future<Either<ApiError, EventEntity>> createEvent(
    Map<String, dynamic> payload,
  ) async {
    final result = await executeRequest<EventModel>(
      request: () => apiClient.post(
        ApiEndpoints.events,
        data: payload,
      ),
      fromJson: (json) => EventModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((model) => model.toEntity());
  }

  Future<Either<ApiError, EventEntity>> updateEvent(
    String eventId,
    Map<String, dynamic> payload,
  ) async {
    final result = await executeRequest<EventModel>(
      request: () => apiClient.patch(
        ApiEndpoints.event(eventId),
        data: payload,
      ),
      fromJson: (json) => EventModel.fromJson(json as Map<String, dynamic>),
    );

    return result.map((model) => model.toEntity());
  }

  Future<Either<ApiError, void>> deleteEvent(String eventId) async {
    return executeRequest<void>(
      request: () => apiClient.delete(ApiEndpoints.event(eventId)),
      fromJson: (_) => null,
    );
  }

  Future<Either<ApiError, void>> joinEvent(String eventId) async {
    return executeRequest<void>(
      request: () => apiClient.post(ApiEndpoints.joinEvent(eventId)),
      fromJson: (_) => null,
    );
  }

  Future<Either<ApiError, void>> leaveEvent(String eventId) async {
    return executeRequest<void>(
      request: () => apiClient.post(ApiEndpoints.leaveEvent(eventId)),
      fromJson: (_) => null,
    );
  }
}
