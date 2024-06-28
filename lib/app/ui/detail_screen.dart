import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rick_and_morty/app/utils/detail_query.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isEpisodesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Character Details",
          style: TextStyle(
            color: Color.fromARGB(255, 69, 81, 94),
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color.fromARGB(126, 214, 169, 55),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Query(
          options: QueryOptions(
            document: getCharacterDetails(),
            variables: {'id': widget.id},
          ),
          builder: (QueryResult result,
              {VoidCallback? refetch, FetchMore? fetchMore}) {
            if (result.hasException) {
              return Center(child: Text(result.exception.toString()));
            }

            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final character = result.data?['character'];
            if (character == null) {
              return const Center(child: Text('Character data not found'));
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(88, 194, 198, 154),
                  border: Border.all(
                    color: Colors.orange,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: character['image'],
                        placeholder: (context, url) => Container(
                          height: 100,
                          color: Colors.grey,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 100,
                          color: Colors.red,
                          alignment: Alignment.center,
                          child: const Icon(Icons.error),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        character['name'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.orange,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Tooltip(
                              message: character['status'],
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 22,
                                    color: character['status'].toLowerCase() ==
                                            "alive"
                                        ? Colors.green
                                        : character['status'].toLowerCase() ==
                                                "unknown"
                                            ? Colors.grey
                                            : Colors.red,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    character['status'],
                                    style: TextStyle(
                                      color: character['status']
                                                  .toLowerCase() ==
                                              "alive"
                                          ? Colors.green
                                          : character['status'].toLowerCase() ==
                                                  "unknown"
                                              ? Colors.grey
                                              : Colors.red,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconAndLabel(
                            label: character['species'],
                            icon: Icons.psychology_outlined,
                          ),
                          IconAndLabel(
                            label: character['gender'],
                            icon: character['gender'].toLowerCase() == 'male'
                                ? Icons.male
                                : character['gender'].toLowerCase() == 'female'
                                    ? Icons.female
                                    : Icons.transgender,
                          ),
                          IconAndLabel(
                            label: character['location']['name'],
                            icon: Icons.location_on_outlined,
                            flexible: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isEpisodesExpanded = !_isEpisodesExpanded;
                        });
                      },
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.only(
                          left: 28,
                          right: 24,
                          top: _isEpisodesExpanded ? 1 : 25,
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Episodes',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isEpisodesExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.orange,
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isEpisodesExpanded)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: ListView.builder(
                            itemCount: character['episode'].length,
                            itemBuilder: (context, index) {
                              final episode = character['episode'][index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.movie,
                                      color: Color.fromARGB(255, 68, 94, 81),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        episode['name'],
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(235, 17, 92, 149),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class IconAndLabel extends StatelessWidget {
  const IconAndLabel({
    super.key,
    required this.label,
    required this.icon,
    this.flexible = false,
  });

  final String label;
  final IconData icon;
  final bool flexible;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 28,
          color: Colors.amber[700],
        ),
        const SizedBox(width: 6),
        if (flexible)
          Expanded(
            child: Text(
              label,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color.fromARGB(250, 5, 153, 244),
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          )
        else
          Text(
            label,
            style: const TextStyle(
              color: Color.fromARGB(248, 66, 83, 97),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
      ],
    );
  }
}
