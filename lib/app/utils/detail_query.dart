import 'package:graphql_flutter/graphql_flutter.dart';

getCharacterDetails() => gql(r"""
  query GetCharacterById($id: ID!) {
    character(id: $id) {
      id
      name
      status
      species
      gender
      image
      location {
        name
      }
      episode {
        name
      }
    }
  }
""");
