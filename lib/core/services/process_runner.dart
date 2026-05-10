import 'dart:io';

const _toolPathEntries = [
  '/opt/homebrew/bin',
  '/usr/local/bin',
  '/opt/local/bin',
  '/usr/bin',
  '/bin',
  '/usr/sbin',
  '/sbin',
];

Map<String, String> toolProcessEnvironment([Map<String, String>? environment]) {
  if (Platform.isWindows) {
    return {...Platform.environment, if (environment != null) ...environment};
  }

  final merged = {
    ...Platform.environment,
    if (environment != null) ...environment,
  };
  final path = merged['PATH'] ?? '';
  final entries = [..._toolPathEntries, if (path.isNotEmpty) path];
  merged['PATH'] = entries.join(':');
  return merged;
}

abstract class ProcessRunner {
  /// Execute a command and return the result.
  /// This is a blocking call that waits for the process to complete.
  Future<ProcessResult> run(
    List<String> args, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = false,
  });

  /// Start a long-running process and return a Stream of output.
  /// This returns a Process object for handling streaming output.
  Future<Process> start(
    List<String> args, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = false,
  });
}

class DefaultProcessRunner implements ProcessRunner {
  @override
  Future<ProcessResult> run(
    List<String> args, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = false,
  }) async {
    if (args.isEmpty) {
      throw ArgumentError('args cannot be empty');
    }

    final executable = args[0];
    final arguments = args.length > 1 ? args.sublist(1).toList() : <String>[];

    try {
      return await Process.run(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        environment: toolProcessEnvironment(environment),
        runInShell: runInShell,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Process> start(
    List<String> args, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = false,
  }) async {
    if (args.isEmpty) {
      throw ArgumentError('args cannot be empty');
    }

    final executable = args[0];
    final arguments = args.length > 1 ? args.sublist(1).toList() : <String>[];

    try {
      return await Process.start(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        environment: toolProcessEnvironment(environment),
        runInShell: runInShell,
      );
    } catch (e) {
      rethrow;
    }
  }
}
