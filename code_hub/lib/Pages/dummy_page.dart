import 'package:code_hub/Models/contest_model.dart';
import 'package:code_hub/Services/clist_api.dart';
import 'package:flutter/material.dart';

class DummyPage extends StatefulWidget {
  const DummyPage({super.key});

  @override
  State<DummyPage> createState() => _DummyPageState();
}

class _DummyPageState extends State<DummyPage> {
  late Future<ContestModel> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = ClistApi().fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ContestModel>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data?.objects == null) {
            return const Center(
              child: Text('No contests available.'),
            );
          } else {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.objects!.length,
              itemBuilder: (context, index) {
                final result = data.objects![index];
                return ListTile(
                  title: Text(result.event ?? 'No event'),
                  subtitle: Text('Start: ${result.start ?? 'No date'}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
