import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/categories.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/listing_card.dart';
import '../listings/listing_detail_screen.dart';
import '../listings/listing_form_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final authProvider = context.watch<AuthProvider>();
    final listings = listingProvider.filteredListings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ListingFormScreen(),
                ),
              );
            },
            tooltip: 'Add Listing',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: listingProvider.setSearchQuery,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for a service',
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: listingProvider.selectedCategory,
              dropdownColor: Theme.of(context).colorScheme.surface,
              decoration: InputDecoration(
                labelText: 'Filter by category',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
              items: ['All', ...listingCategories]
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) listingProvider.setCategory(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Near You',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: listings.isEmpty
                ? Center(
                    child: Text(
                      'No listings found.',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final item = listings[index];
                      final isOwner = item.createdBy == authProvider.user?.uid;
                      return ListingCard(
                        listing: item,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ListingDetailScreen(listing: item),
                            ),
                          );
                        },
                        onEdit: isOwner
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        ListingFormScreen(existing: item),
                                  ),
                                );
                              }
                            : null,
                        onDelete: isOwner
                            ? () async {
                                await context
                                    .read<ListingProvider>()
                                    .deleteListing(item.id);
                              }
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
