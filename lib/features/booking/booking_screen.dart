import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, required this.tourId});

  final String tourId;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.bookingTitle)),
      body: Stepper(
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              FilledButton(
                onPressed: details.onStepContinue,
                child: Text(l.bookingContinue),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: details.onStepCancel,
                child: Text(l.bookingBack),
              ),
            ],
          ),
        ),
        steps: [
          Step(
            title: Text(l.bookingStepDateGuests),
            content: Text(l.bookingStepDateGuestsContent(tourId)),
            isActive: true,
          ),
          Step(
            title: Text(l.bookingStepContact),
            content: Text(l.bookingStepContactContent),
          ),
          Step(
            title: Text(l.bookingStepPayment),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.bookingStepPaymentContent),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context.go('/discover'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l.bookingCompleteDemo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

