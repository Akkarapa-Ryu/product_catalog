
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchFilterPage extends ConsumerStatefulWidget {
  const SearchFilterPage({super.key});

  @override
  ConsumerState<SearchFilterPage> createState() =>
      _SearchFilterPageState();
}

class _SearchFilterPageState
    extends ConsumerState<SearchFilterPage> {

  String selectedState = 'Loading';

    Widget _buildArchitectureCard() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: const ListTile(
        leading: Icon(Icons.layers),
        title: Text('Riverpod StateNotifier + Dio + Repository'),
        subtitle: Text(
          'MVI / State Pattern • Clean Architecture Data Flow',
        ),
      ),
    );
  }

  Widget _buildStateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'Loading',
            label: Text('Loading'),
            icon: Icon(Icons.refresh),
          ),
          ButtonSegment(
            value: 'Dio Error',
            label: Text('Dio Error'),
            icon: Icon(Icons.error_outline),
          ),
          ButtonSegment(
            value: 'Empty State',
            label: Text('Empty State'),
            icon: Icon(Icons.inbox_outlined),
          ),
        ],
        selected: {selectedState},
        onSelectionChanged: (value) {
          setState(() {
            selectedState = value.first;
          });
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedState) {
      case 'Loading':
        return const Center(
          child: CircularProgressIndicator(),
        );

      case 'Dio Error':
        return const Center(
          child: Text('Unable to load products'),
        );

      case 'Empty State':
        return const Center(
          child: Text('No products found'),
        );

      default:
        return const SizedBox.shrink();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        title: const Text('Search & Filter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          CircleAvatar(
            backgroundColor: Colors.blue.shade800,
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10,)
        ],
      ),

      body: Column(
        children: [
          // Architecture Information
          _buildArchitectureCard(),

          // State Selector
          _buildStateSelector(),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }


}
