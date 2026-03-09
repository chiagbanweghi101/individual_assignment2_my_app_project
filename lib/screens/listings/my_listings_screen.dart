import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/listing_provider.dart';
import '../../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'listing_form_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final listings = listingProvider.myListings;

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: listings.isEmpty
          ? Center(
              child: Text(
                'You have not created listings yet.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final item = listings[index];
                return ListingCard(
                  listing: item,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ListingDetailScreen(listing: item),
                      ),
                    );
                  },
                  onEdit: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ListingFormScreen(existing: item),
                      ),
                    );
                  },
                  onDelete: () async {
                    await context.read<ListingProvider>().deleteListing(item.id);
                  },
                );
              },
            ),
    );
  }
}
