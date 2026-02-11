import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page object for interacting with the Colony Wizard in integration tests.
class ColonyWizardRobot {
  ColonyWizardRobot(this.tester);

  final WidgetTester tester;

  // ============ Common Finders ============

  Finder get wizardTitle => find.text('Colony Setup Wizard');
  Finder get nextButton => find.text('Next');
  Finder get backButton => find.text('Back');
  Finder get closeButton => find.byIcon(Icons.close);

  // ============ Welcome Step ============

  Finder get welcomeTitle => find.text('Welcome to Colony Setup');
  Finder get getStartedButton => find.text('Get Started');

  // ============ Strains & Genotypes Step ============

  Finder get strainsGenotypesTitle => find.text('Strains & Genotypes');
  Finder get strainNameField => find.widgetWithText(TextField, 'Strain Name');
  Finder get addStrainButton => find.widgetWithText(FilledButton, 'Add');
  Finder get strainsSection => find.text('STRAINS');
  Finder get genotypesSection => find.text('GENOTYPES');

  Finder geneNameField(int index) =>
      find.widgetWithText(TextField, 'Gene Name').at(index);
  Finder alleleNameField(int index) =>
      find.widgetWithText(TextField, 'Allele Name').at(index);
  Finder addGeneButton(int index) =>
      find.widgetWithText(OutlinedButton, 'Add Gene').at(index);
  Finder addAlleleButton(int index) =>
      find.widgetWithText(OutlinedButton, 'Add Allele').at(index);

  // ============ Racks Step ============

  Finder get racksTitle => find.text('Racks');
  Finder get rackNameField => find.widgetWithText(TextField, 'Rack Name (optional)');
  Finder get addRackButton => find.widgetWithText(FilledButton, 'Add Rack');
  Finder get smallRackOption => find.text('Small');
  Finder get mediumRackOption => find.text('Medium');
  Finder get largeRackOption => find.text('Large');
  Finder get customSizeOption => find.text('Custom Size');

  // ============ Cages & Animals Step ============

  Finder get cagesAnimalsTitle => find.text('Cages & Animals');
  Finder get addMaleButton => find.text('Add Male');
  Finder get addFemaleButton => find.text('Add Female');
  Finder get addUnknownButton => find.text('Add Unknown');
  Finder get matingSectionTitle => find.text('Mating');
  Finder get matingTagField => find.widgetWithText(TextField, 'Mating Tag');
  Finder get litterStrainField => find.text('Litter Strain');
  Finder get saveButton => find.widgetWithText(FilledButton, 'Save');
  Finder get updateButton => find.widgetWithText(FilledButton, 'Update');
  Finder get cancelButton => find.text('Cancel');
  Finder get cageTagField => find.widgetWithText(TextField, 'Cage Tag *');

  // Pup counters
  Finder get pupMaleIncrement => find.byIcon(Icons.add).at(0);
  Finder get pupFemaleIncrement => find.byIcon(Icons.add).at(1);

  // ============ Review Step ============

  Finder get reviewTitle => find.text('Review');
  Finder get finishButton => find.text('Finish');

  // ============ Navigation Methods ============

  /// Verifies the wizard is displayed
  Future<void> verifyWizardDisplayed() async {
    expect(wizardTitle, findsOneWidget);
  }

  /// Taps the Next button to proceed to next step
  Future<void> tapNext() async {
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
  }

  /// Taps the Back button to go to previous step
  Future<void> tapBack() async {
    await tester.tap(backButton);
    await tester.pumpAndSettle();
  }

  /// Closes the wizard
  Future<void> closeWizard() async {
    await tester.tap(closeButton);
    await tester.pumpAndSettle();
  }

  // ============ Welcome Step Methods ============

  /// Verifies welcome step is displayed
  Future<void> verifyWelcomeStepDisplayed() async {
    expect(welcomeTitle, findsOneWidget);
  }

  /// Taps Get Started button
  Future<void> tapGetStarted() async {
    await tester.tap(getStartedButton);
    await tester.pumpAndSettle();
  }

  // ============ Strains & Genotypes Step Methods ============

  /// Verifies strains & genotypes step is displayed
  Future<void> verifyStrainsStepDisplayed() async {
    expect(strainsGenotypesTitle, findsOneWidget);
    expect(strainsSection, findsOneWidget);
    expect(genotypesSection, findsOneWidget);
  }

  /// Adds a strain with the given name
  Future<void> addStrain(String name) async {
    await tester.enterText(strainNameField, name);
    await tester.pump();
    await tester.tap(addStrainButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Verifies a strain was added
  Future<void> verifyStrainAdded(String name) async {
    expect(find.text(name), findsWidgets);
  }

  /// Adds a gene with the given name
  Future<void> addGene(String name) async {
    // Find the gene text field and add button
    final geneFields = find.widgetWithText(TextField, 'Gene Name');
    if (geneFields.evaluate().isNotEmpty) {
      await tester.enterText(geneFields.first, name);
      await tester.pump();
      
      final addButtons = find.widgetWithText(OutlinedButton, 'Add Gene');
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }
    }
  }

  /// Verifies a gene was added
  Future<void> verifyGeneAdded(String name) async {
    expect(find.text(name), findsWidgets);
  }

  /// Adds an allele with the given name
  Future<void> addAllele(String name) async {
    // Find the allele text field and add button
    final alleleFields = find.widgetWithText(TextField, 'Allele Name');
    if (alleleFields.evaluate().isNotEmpty) {
      await tester.enterText(alleleFields.first, name);
      await tester.pump();
      
      final addButtons = find.widgetWithText(OutlinedButton, 'Add Allele');
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }
    }
  }

  /// Verifies an allele was added
  Future<void> verifyAlleleAdded(String name) async {
    expect(find.text(name), findsWidgets);
  }

  // ============ Racks Step Methods ============

  /// Verifies racks step is displayed
  Future<void> verifyRacksStepDisplayed() async {
    expect(racksTitle, findsOneWidget);
    expect(addRackButton, findsOneWidget);
  }

  /// Adds a rack with the given name and template
  Future<void> addRack({String? name, String template = 'small'}) async {
    // Enter name if provided
    if (name != null) {
      await tester.enterText(rackNameField, name);
      await tester.pump();
    }

    // Select template
    final templateFinder = find.text(_getTemplateLabel(template));
    if (templateFinder.evaluate().isNotEmpty) {
      await tester.tap(templateFinder);
      await tester.pump();
    }

    // Tap Add Rack
    await tester.tap(addRackButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  String _getTemplateLabel(String template) {
    switch (template) {
      case 'small':
        return 'Small';
      case 'medium':
        return 'Medium';
      case 'large':
        return 'Large';
      case 'extraLarge':
        return 'Extra Large';
      default:
        return 'Small';
    }
  }

  /// Verifies a rack was added
  Future<void> verifyRackAdded(String name) async {
    expect(find.text(name), findsWidgets);
  }

  // ============ Cages & Animals Step Methods ============

  /// Verifies cages & animals step is displayed
  Future<void> verifyCagesStepDisplayed() async {
    expect(cagesAnimalsTitle, findsOneWidget);
  }

  /// Taps on an empty cell to add a cage
  Future<void> tapEmptyCell() async {
    // Look for the add icon in empty cells
    final addIcons = find.byIcon(Icons.add);
    if (addIcons.evaluate().isNotEmpty) {
      await tester.tap(addIcons.first);
      await tester.pumpAndSettle();
    }
  }

  /// Taps on an existing cage to edit it
  Future<void> tapExistingCage(String cageTag) async {
    final cageFinder = find.text(cageTag);
    if (cageFinder.evaluate().isNotEmpty) {
      await tester.tap(cageFinder);
      await tester.pumpAndSettle();
    }
  }

  /// Verifies cage dialog is displayed
  Future<void> verifyCageDialogDisplayed() async {
    expect(addMaleButton, findsOneWidget);
    expect(addFemaleButton, findsOneWidget);
  }

  /// Sets the cage tag
  Future<void> setCageTag(String tag) async {
    await tester.enterText(cageTagField, tag);
    await tester.pump();
  }

  /// Adds a male animal
  Future<void> addMale() async {
    await tester.tap(addMaleButton);
    await tester.pumpAndSettle();
  }

  /// Adds a female animal
  Future<void> addFemale() async {
    await tester.tap(addFemaleButton);
    await tester.pumpAndSettle();
  }

  /// Verifies mating section is displayed
  Future<void> verifyMatingSectionDisplayed() async {
    expect(matingSectionTitle, findsOneWidget);
  }

  /// Verifies mating section is NOT displayed
  Future<void> verifyMatingSectionNotDisplayed() async {
    expect(matingSectionTitle, findsNothing);
  }

  /// Verifies mating tag is auto-generated (not empty)
  Future<void> verifyMatingTagGenerated() async {
    // Find the mating tag text field
    final matingTagFields = find.widgetWithText(TextField, 'Mating Tag');
    expect(matingTagFields, findsOneWidget);

    // Get the TextField widget and check its controller
    final textField = tester.widget<TextField>(matingTagFields);
    expect(textField.controller?.text.isNotEmpty, isTrue,
        reason: 'Mating tag should be auto-generated');
    
    debugPrint('✅ Mating tag auto-generated: "${textField.controller?.text}"');
  }

  /// Verifies mating tag contains expected text
  Future<void> verifyMatingTagContains(String expected) async {
    final matingTagFields = find.widgetWithText(TextField, 'Mating Tag');
    expect(matingTagFields, findsOneWidget);

    final textField = tester.widget<TextField>(matingTagFields);
    expect(textField.controller?.text.contains(expected), isTrue,
        reason: 'Mating tag should contain "$expected"');
  }

  /// Verifies litter strain picker is displayed
  Future<void> verifyLitterStrainDisplayed() async {
    expect(litterStrainField, findsOneWidget);
  }

  /// Adds pups to the litter
  Future<void> addPups({int male = 0, int female = 0, int unknown = 0}) async {
    // Find increment buttons in the pup counter section
    final incrementButtons = find.byIcon(Icons.add);
    
    for (int i = 0; i < male; i++) {
      if (incrementButtons.evaluate().isNotEmpty) {
        await tester.tap(incrementButtons.at(0));
        await tester.pump();
      }
    }
    
    for (int i = 0; i < female; i++) {
      if (incrementButtons.evaluate().length > 1) {
        await tester.tap(incrementButtons.at(1));
        await tester.pump();
      }
    }
    
    for (int i = 0; i < unknown; i++) {
      if (incrementButtons.evaluate().length > 2) {
        await tester.tap(incrementButtons.at(2));
        await tester.pump();
      }
    }
  }

  /// Saves the cage
  Future<void> saveCage() async {
    final saveBtn = find.widgetWithText(FilledButton, 'Save');
    if (saveBtn.evaluate().isNotEmpty) {
      await tester.tap(saveBtn);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }
  }

  /// Updates the cage (edit mode)
  Future<void> updateCage() async {
    final updateBtn = find.widgetWithText(FilledButton, 'Update');
    if (updateBtn.evaluate().isNotEmpty) {
      await tester.tap(updateBtn);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }
  }

  /// Cancels the cage dialog
  Future<void> cancelCageDialog() async {
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
  }

  // ============ Review Step Methods ============

  /// Verifies review step is displayed
  Future<void> verifyReviewStepDisplayed() async {
    expect(reviewTitle, findsOneWidget);
  }

  /// Taps Finish button
  Future<void> tapFinish() async {
    await tester.tap(finishButton);
    await tester.pumpAndSettle();
  }

  // ============ Utility Methods ============

  /// Waits for network operations
  Future<void> waitForNetwork({int seconds = 5}) async {
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }

  /// Scrolls down to find an element
  Future<void> scrollToFind(Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      100,
      scrollable: find.byType(Scrollable).first,
    );
  }
}
