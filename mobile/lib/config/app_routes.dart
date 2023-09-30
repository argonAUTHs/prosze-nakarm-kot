import 'package:flutter/material.dart';

import '../presentation/views/form_submitted_view.dart';
import '../presentation/views/main_app_view.dart';
import '../presentation/views/request_list_view.dart';
import '../presentation/views/request_sent_view.dart';
import '../presentation/views/scan_to_authorize_view.dart';
import '../presentation/views/scan_to_request_view.dart';


class AppRoutes {
  static Route? onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const MainAppView());
      case '/authorize':
        return _materialRoute(const ScanToAuthorizeView());
      case '/requestlist':
        return _materialRoute(const RequestListView());
      case '/request':
        return _materialRoute(const ScanToRequestView());
      case '/success':
        return _materialRoute(const FormSubmittedView());
      case '/requestsent':
        return _materialRoute(const RequestSentView());
      default:
        return null;
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}