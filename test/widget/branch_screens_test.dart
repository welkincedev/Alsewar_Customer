import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/models/business_hour.dart';
import 'package:carwashapp/features/branches/screens/branch_detail_screen.dart';
import 'package:carwashapp/features/branches/screens/branch_list_screen.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_providers.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_viewmodel.dart';

class FakeBranchListViewModel extends BranchListViewModel {
  final List<Branch> initialBranches;

  FakeBranchListViewModel({this.initialBranches = const []});

  @override
  Future<List<Branch>> build() async {
    return initialBranches;
  }
}

void main() {
  group('Branch Screens Widget Tests', () {
    testWidgets('BranchListScreen displays list of branches', (
      WidgetTester tester,
    ) async {
      const mockBranch = Branch(
        id: 1,
        name: 'Dubai Downtown Branch',
        code: 'DXB01',
        address: 'Downtown Boulevard',
        city: 'Dubai',
        phone: '+97141234567',
        email: 'dxb@alsewar.com',
        latitude: 25.1972,
        longitude: 55.2744,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            branchListViewModelProvider.overrideWith(
              () => FakeBranchListViewModel(initialBranches: [mockBranch]),
            ),
          ],
          child: const MaterialApp(home: BranchListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Our Branches'), findsOneWidget);
      expect(find.text('Dubai Downtown Branch'), findsOneWidget);
      expect(find.text('Code: DXB01'), findsOneWidget);
      expect(find.text('Downtown Boulevard, Dubai'), findsOneWidget);
    });

    testWidgets('BranchDetailScreen displays contact info and weekly hours', (
      WidgetTester tester,
    ) async {
      const mockBranch = Branch(
        id: 1,
        name: 'Dubai Downtown Branch',
        code: 'DXB01',
        address: 'Downtown Boulevard',
        city: 'Dubai',
        phone: '+97141234567',
        email: 'dxb@alsewar.com',
      );

      const mockHours = [
        BusinessHour(
          id: 1,
          dayOfWeek: 1,
          dayName: 'Monday',
          openingTime: '08:00:00',
          closingTime: '20:00:00',
        ),
        BusinessHour(id: 7, dayOfWeek: 7, dayName: 'Sunday', isClosed: true),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            branchDetailProvider(1)
                .overrideWith((ref) => Future.value(mockBranch)),
            branchHoursProvider(1)
                .overrideWith((ref) => Future.value(mockHours)),
          ],
          child: const MaterialApp(home: BranchDetailScreen(branchId: 1)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Branch Details'), findsOneWidget);
      expect(find.text('Dubai Downtown Branch'), findsOneWidget);
      expect(find.text('Weekly Operating Hours'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('8:00 AM - 8:00 PM'), findsOneWidget);
      expect(find.text('Sunday'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
    });
  });
}
