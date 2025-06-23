import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:vm_service/vm_service.dart';

class ServiceManagerService {
  const ServiceManagerService._();

  /// Evaluates the expression in the isolate's root library.
  static Future<Response> evalInRunningApp(String expressionText) async {
    final isolateRef = serviceManager.isolateManager.selectedIsolate.value!;

    final isolate = serviceManager.isolateManager.isolateState(isolateRef);

    final isolateId = isolateRef.id!;

    return await serviceManager.service!.evaluate(
      isolateId,
      (await isolate.isolate)!.rootLib!.id!,
      expressionText,
    );
  }

  static Future<Obj?> getObject(String objectId) async {
    final isolateId = serviceManager.isolateManager.selectedIsolate.value!.id!;

    return await serviceManager.service?.getObject(isolateId, objectId);
  }
}
