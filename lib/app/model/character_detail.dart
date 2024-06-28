// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:rick_and_morty/app/widgets/details_widget.dart';

class CharacterDetail {
  final String id;
  final String gender;
  final String type;
  final String species;
  final String image;
  final String name;
  final String status;
  final String location;
  final String episodes;
  CharacterDetail({
    required this.id,
    required this.gender,
    required this.type,
    required this.species,
    required this.image,
    required this.name,
    required this.status,
    required this.location,
    required this.episodes,
  });

  CharacterDetail copyWith({
    String? id,
    String? gender,
    String? type,
    String? species,
    String? image,
    String? name,
    String? status,
    String? location,
    String? episodes,
  }) {
    return CharacterDetail(
      id: id ?? this.id,
      gender: gender ?? this.gender,
      type: type ?? this.type,
      species: species ?? this.species,
      image: image ?? this.image,
      name: name ?? this.name,
      status: status ?? this.status,
      location: location ?? this.location,
      episodes: location ?? this.episodes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'gender': gender,
      'type': type,
      'species': species,
      'image': image,
      'name': name,
      'status': status,
      'location': location,
      'episodes': episodes,
    };
  }

  factory CharacterDetail.fromMap(Map<String, dynamic> map) {
    return CharacterDetail(
      id: map['id'] as String,
      gender: map['gender'] as String,
      type: map['type'] as String,
      species: map['species'] as String,
      image: map['image'] as String,
      name: map['name'] as String,
      status: map['status'] as String,
      location:
          map['location'] == null ? "" : map['location']['name'] as String,
      episodes:
          map['episodes'] == null ? "" : map['episodes']['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CharacterDetail.fromJson(String source) =>
      CharacterDetail.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CharacterDetail(id: $id, gender: $gender, type: $type, species: $species, image: $image, name: $name, status: $status, location: $location, episodes: $episodes)';
  }

  @override
  bool operator ==(covariant CharacterDetail other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.gender == gender &&
        other.type == type &&
        other.species == species &&
        other.image == image &&
        other.name == name &&
        other.status == status &&
        other.location == location &&
        other.episodes == episodes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        gender.hashCode ^
        type.hashCode ^
        species.hashCode ^
        image.hashCode ^
        name.hashCode ^
        status.hashCode ^
        location.hashCode ^
        episodes.hashCode;
  }

  map(DetailsWidget Function(dynamic e) param0) {}
}
