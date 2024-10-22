import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rick_and_morty/app/model/character.dart';
import 'package:rick_and_morty/app/utils/query.dart';
import 'package:rick_and_morty/app/widgets/character_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _genderFilter;
  String? _speciesFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              "assets/logo.png",
              // color: Color.fromARGB(149, 4, 194, 236),
              height: 56,
            ),
            const SizedBox(width: 28),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: 'Search name',
                  hintText: 'Rick',
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 155, 148, 148),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Flexible(
                    child: _buildDropdown(
                      label: 'Gender',
                      value: _genderFilter,
                      items: ['All', 'Male', 'Female', 'Unknown'],
                      onChanged: (value) {
                        setState(() {
                          _genderFilter = value == 'All' ? null : value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: _buildDropdown(
                      label: 'Species',
                      value: _speciesFilter,
                      items: ['All', 'Human', 'Alien', 'Humanoid', 'Unknown'],
                      onChanged: (value) {
                        setState(() {
                          _speciesFilter = value == 'All' ? null : value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Query(
                  builder: (result, {fetchMore, refetch}) {
                    // We have data
                    if (result.data != null) {
                      int? nextPage = 1;
                      List<Character> characters =
                          (result.data!["characters"]["results"] as List)
                              .map((e) => Character.fromMap(e))
                              .toList();

                      // to filter characters based on search query
                      if (_searchQuery.isNotEmpty) {
                        characters = characters
                            .where((character) => character.name
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()))
                            .toList();
                      }

                      // filtering with gender and species
                      characters = characters.where((character) {
                        bool matches = true;
                        if (_genderFilter != null &&
                            _genderFilter!.isNotEmpty &&
                            _genderFilter != 'All') {
                          matches = matches &&
                              character.gender.toLowerCase() ==
                                  _genderFilter!.toLowerCase();
                        }
                        if (_speciesFilter != null &&
                            _speciesFilter!.isNotEmpty &&
                            _speciesFilter != 'All') {
                          matches = matches &&
                              character.species.toLowerCase() ==
                                  _speciesFilter!.toLowerCase();
                        }
                        return matches;
                      }).toList();

                      nextPage = result.data!["characters"]["info"]["next"];

                      // when is there is no match found
                      if (characters.isEmpty && _searchQuery.isNotEmpty) {
                        return const Center(
                          child: Text(
                            "Search result not found!",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Serif',
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await refetch!();
                          nextPage = 1;
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Center(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: characters
                                      .map((e) => CharacterWidget(character: e))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              if (nextPage != null)
                                ElevatedButton(
                                  onPressed: () async {
                                    FetchMoreOptions opts = FetchMoreOptions(
                                      variables: {'page': nextPage},
                                      updateQuery: (previousResultData,
                                          fetchMoreResultData) {
                                        final List<dynamic> repos = [
                                          ...previousResultData!["characters"]
                                              ["results"] as List<dynamic>,
                                          ...fetchMoreResultData!["characters"]
                                              ["results"] as List<dynamic>
                                        ];
                                        fetchMoreResultData["characters"]
                                            ["results"] = repos;
                                        return fetchMoreResultData;
                                      },
                                    );
                                    await fetchMore!(opts);
                                  },
                                  child: result.isLoading
                                      ? const CircularProgressIndicator
                                          .adaptive()
                                      : const Text("Load More"),
                                ),
                            ],
                          ),
                        ),
                      );
                    } else if (result.data == null) {
                      return Center(
                        child: const Text(
                          "Data Not Found!",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.orange,
                          ),
                        ),
                      );
                    } else if (result.isLoading) {
                      return const Center(
                        child: Text("Loading..."),
                      );
                    } else {
                      return const Center(
                        child: Center(
                          child: Text(
                            "Something went wrong",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  options: QueryOptions(
                      fetchPolicy: FetchPolicy.cacheAndNetwork,
                      document: getAllCharachters(),
                      variables: {
                        "page": 1,
                        "species": _speciesFilter ?? 'None',
                        "gender": _genderFilter,
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    'By Ehenew Amogne',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 116, 121, 84),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
