// Openapi Generator last run: : 2024-10-14T10:43:07.969834
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  additionalProperties:
      DioProperties(pubName: 'traileyes_api', pubDescription: 'Trail Eyes API'),
  inputSpec: RemoteSpec(path: 'https://api.nightly.traileyes.net/openapi.json'),
  generatorName: Generator.dio,
  runSourceGenOnOutput: true,
  outputDirectory: 'api/traileyes_api',
)
class TrailEyesApi {}
