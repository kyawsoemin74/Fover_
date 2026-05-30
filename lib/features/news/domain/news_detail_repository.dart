import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/news/domain/models/news_model.dart';

abstract class NewsDetailRepository {
  Future<ApiResult<NewsInfo>> fetchNewsDetail(String articleId, {bool forceRefresh = false});
}
