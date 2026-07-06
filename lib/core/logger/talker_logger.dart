import 'package:snapconnect/core/logger/app_logger.dart';
import 'package:talker/talker.dart';

class TalkerLoggerImpl extends AppLogger {
  final Talker _talker;

  TalkerLoggerImpl(this._talker);

  @override
  void debug(String message) => _talker.debug(message);

  @override
  void error(String message, [Object? exception, StackTrace? stackTrace]) =>
      _talker.error(message, exception, stackTrace);

  @override
  void good(String message) => _talker.log(message, pen: AnsiPen()..green());

  @override
  void handle(Object exception, StackTrace stackTrace, [String? message]) =>
      _talker.handle(exception, stackTrace, message);

  @override
  void info(String message) => _talker.info(message);

  @override
  void verbose(String message) => _talker.verbose(message);

  @override
  void warning(String message) => _talker.warning(message);

  @override
  get coreLogger => _talker;
}
