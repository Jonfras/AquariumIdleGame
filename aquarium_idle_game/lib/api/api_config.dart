import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  additionalProperties: AdditionalProperties(
    pubName: 'aquarium_api',
    pubAuthor: 'Jonas Kreuzhuber',
  ),
  inputSpecFile: 'openapi_spec.json', 
  generatorName: Generator.dart,
  outputDirectory: 'lib/api/generated',
)
class ApiConfig extends OpenapiGeneratorConfig {}