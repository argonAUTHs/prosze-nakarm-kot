abstract class MatchSchemaEvent{
  final String? schema;

  const MatchSchemaEvent({this.schema});
}

class MatchSchema extends MatchSchemaEvent{
  const MatchSchema(String schema):super(schema: schema);
}