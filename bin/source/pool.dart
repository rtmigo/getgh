import 'dart:async';
import 'dart:collection';


// TODO add to schedulers

abstract class Task<R> {
  Future<R> get result;

  bool get isCompleted;
}

class CompletableTask<R> implements Task<R> {
  final Future<R> Function() function;

  @override
  Future<R> get result => completer.future;

  @override
  bool get isCompleted => completer.isCompleted;

  Completer<R> completer = Completer<R>();

  CompletableTask(this.function);
}

class TaskPool<R> {
  final int concurrency;
  final _tasks = Queue<CompletableTask<R>>();

  TaskPool({this.concurrency = 8});

  Task<R> add(final Future<R> Function() func) {
    final t = CompletableTask(func);
    _tasks.addLast(t);
    _maybeRunTasks();
    return t;
  }

  Future<R> run(final Future<R> Function() func) => add(func).result;

  int _currentlyRunning = 0;
  int get currentlyRunning => _currentlyRunning;

  void _maybeRunTasks() {
    // Это синхронная функция, которая запускает задачи асинхронно рекурсивно.
    // При избыточной длине очереди мы (наверно) можем столкнуться с
    // переполнением стека.

    assert (_currentlyRunning<=concurrency);  
    
    while (_currentlyRunning < concurrency && _tasks.isNotEmpty) {
      final runMe = _tasks.removeFirst();
      _currentlyRunning += 1;
      Future.microtask(() async {
        assert(!runMe.completer.isCompleted);

        try {
          assert(!runMe.completer.isCompleted);
          final r = await runMe.function();
          runMe.completer.complete(r);
        } catch (error, trace) {
          assert(!runMe.completer.isCompleted);
          runMe.completer.completeError(error, trace);
        }

        assert(runMe.completer.isCompleted);
      }).whenComplete(() {
        assert(runMe.isCompleted);
        _currentlyRunning--;
        assert(_currentlyRunning >= 0);
        _maybeRunTasks();
      });
    }

    assert(_currentlyRunning==concurrency || _tasks.isEmpty);
  }
}
