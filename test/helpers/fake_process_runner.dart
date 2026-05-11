import 'dart:io';

import 'package:fastadb/core/services/process_runner.dart';

class FakeProcessRunner implements ProcessRunner {
  FakeProcessRunner(this._handler);

  final Future<ProcessResult> Function(List<String> args) _handler;
  final List<List<String>> calls = [];

  @override
  Future<ProcessResult> run(
    List<String> args, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = false,
  }) async {
    calls.add(args);
    return _handler(args);
  }

  @override
  Future<Process> start(
    List<String> args, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = false,
  }) {
    throw UnimplementedError('FakeProcessRunner.start is not used in tests');
  }
}

ProcessResult processResult({
  int exitCode = 0,
  Object? stdout = '',
  Object? stderr = '',
}) {
  return ProcessResult(42, exitCode, stdout, stderr);
}
