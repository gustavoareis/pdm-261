import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import 'article_screen.dart';
import 'news_data.dart';

const String appGroupId = 'group.com.mydomain.homescreenwidgets';
const String iOSWidgetName = 'NewsWidgets';
const String androidWidgetName = 'NewsWidget';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

void updateHeadline(NewsArticle newHeadline) {
  if (kIsWeb) {
    return;
  }

  HomeWidget.saveWidgetData<String>('headline_title', newHeadline.title);
  HomeWidget.saveWidgetData<String>(
    'headline_description',
    newHeadline.description,
  );
  HomeWidget.updateWidget(
    iOSName: iOSWidgetName,
    androidName: androidWidgetName,
  );
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      HomeWidget.setAppGroupId(appGroupId);
    }

    final newHeadline = getNewsStories()[0];
    updateHeadline(newHeadline);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Gustavo Almeida dos Reis'),
        ),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (context, idx) {
          return const Divider();
        },
        itemCount: getNewsStories().length,
        itemBuilder: (context, idx) {
          final article = getNewsStories()[idx];
          return ListTile(
            key: Key('$idx ${article.hashCode}'),
            title: Text(article.title),
            subtitle: Text(article.description),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<ArticleScreen>(
                  builder: (context) {
                    return ArticleScreen(article: article);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
