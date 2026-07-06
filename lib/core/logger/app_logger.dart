abstract class AppLogger {
  void verbose(String message); // custom log level for very detailed messages
  void debug(String message); // standard log level for debugging messages
  void info(String message); // standard log level for informational messages
  void warning(String message); // custom log level for warnings
  void good(String message); // custom log level for success messages
  void error(
    String message, [
    Object? exception,
    StackTrace? stackTrace,
  ]); // standard log level for errors
  void handle(
    Object exception,
    StackTrace stackTrace, [
    String? message,
  ]); // method for handling uncaught exceptions

  dynamic get coreLogger; // Expose the underlying logger for advanced use cases
}
