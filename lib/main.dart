import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
void main() => runApp(const NewsApp());
class NewsApp extends StatelessWidget {
  const NewsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      home: const NewsHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});
  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}
class _NewsHomePageState extends State<NewsHomePage> {
  List articles = [];
  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final url = Uri.parse(
      'https://newsapi.org/v2/top-headlines?country=us&apiKey=ec4fe743db114677b3b27d381d0a85a5',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        articles = json['articles'];
      });
    } else {
      print('Failed to load news: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Headlines')),
      body: articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailPage(
                    title: article['title'] ?? 'No Title',
                    description: article['description'] ?? 'No Description',
                    imageUrl: article['urlToImage'],
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  article['urlToImage'] != null
                      ? Image.network(article['urlToImage'])
                      : const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      article['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

        },
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;

  const NewsDetailPage({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Image.network(imageUrl!)
            else
              const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                description.isNotEmpty ? description : 'No description available .',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
