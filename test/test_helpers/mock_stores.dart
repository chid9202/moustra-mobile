import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/stores/animal_store.dart';
import 'package:moustra/stores/cage_store.dart';
import 'mock_data.dart';

/// Mock store utilities for testing
class MockStores {
  static List<AnimalStoreDto>? _mockAnimals;
  static List<CageStoreDto>? _mockCages;

  /// Sets up mock data for animal store
  static void setupMockAnimals(List<AnimalStoreDto> animals) {
    _mockAnimals = animals;
    animalStore.value = animals;
  }

  /// Sets up mock data for cage store
  static void setupMockCages(List<CageStoreDto> cages) {
    _mockCages = cages;
    cageStore.value = cages;
  }

  /// Sets up default mock data for both stores
  static void setupDefaultMocks() {
    setupMockAnimals(MockDataFactory.createAnimalStoreDtoList(5));
    setupMockCages(MockDataFactory.createCageStoreDtoList(3));
  }

  /// Clears all mock data
  static void clearMocks() {
    _mockAnimals = null;
    _mockCages = null;
    animalStore.value = null;
    cageStore.value = null;
  }

  /// Overrides the getAnimalsHook to return mock data
  static Future<List<AnimalStoreDto>> mockGetAnimalsHook() async {
    return _mockAnimals ?? MockDataFactory.createAnimalStoreDtoList(5);
  }

  /// Overrides the getCagesHook to return mock data
  static Future<List<CageStoreDto>> mockGetCagesHook() async {
    return _mockCages ?? MockDataFactory.createCageStoreDtoList(3);
  }
}

/// Test wrapper that provides mocked store hooks
class MockedStoreProvider extends StatelessWidget {
  final Widget child;
  final List<AnimalStoreDto>? mockAnimals;
  final List<CageStoreDto>? mockCages;

  const MockedStoreProvider({
    super.key,
    required this.child,
    this.mockAnimals,
    this.mockCages,
  });

  @override
  Widget build(BuildContext context) {
    // Set up mocks before building
    if (mockAnimals != null) {
      MockStores.setupMockAnimals(mockAnimals!);
    }
    if (mockCages != null) {
      MockStores.setupMockCages(mockCages!);
    }

    return child;
  }
}
