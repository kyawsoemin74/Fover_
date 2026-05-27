import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/news/domain/models/news_model.dart';

abstract class NewsRepository {
  Future<ApiResult<List<NewsInfo>>> fetchNews({bool forceRefresh = false});
}
