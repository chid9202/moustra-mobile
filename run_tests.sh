#!/bin/bash

# Moustra Mobile Test Runner Script
# This script runs different test suites for the Moustra mobile application

set -e

echo "🧪 Moustra Mobile Test Suite"
echo "=============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to run tests with coverage
run_tests_with_coverage() {
    print_status "Running tests with coverage..."
    flutter test --coverage
    if [ $? -eq 0 ]; then
        print_success "Tests completed successfully with coverage"
        print_status "Coverage report generated in coverage/lcov.info"
    else
        print_error "Tests failed"
        exit 1
    fi
}

# Function to run specific test file
run_test_file() {
    local test_file=$1
    print_status "Running test file: $test_file"
    flutter test "$test_file"
    if [ $? -eq 0 ]; then
        print_success "Test file $test_file passed"
    else
        print_error "Test file $test_file failed"
        exit 1
    fi
}

# Function to run all shared widget tests
run_shared_widget_tests() {
    print_status "Running all shared widget tests..."
    
    local test_files=(
        "test/widgets/shared/button_test.dart"
        "test/widgets/shared/select_animal_test.dart"
        "test/widgets/shared/select_cage_test.dart"
        "test/widgets/shared/select_date_test.dart"
        "test/widgets/shared/multi_select_animal_test.dart"
    )
    
    local passed=0
    local failed=0
    
    for test_file in "${test_files[@]}"; do
        if [ -f "$test_file" ]; then
            print_status "Running $test_file..."
            if flutter test "$test_file" > /dev/null 2>&1; then
                print_success "✓ $test_file"
                ((passed++))
            else
                print_error "✗ $test_file"
                ((failed++))
            fi
        else
            print_warning "Test file not found: $test_file"
        fi
    done
    
    echo ""
    print_status "Shared Widget Tests Summary:"
    print_success "Passed: $passed"
    if [ $failed -gt 0 ]; then
        print_error "Failed: $failed"
    else
        print_success "Failed: $failed"
    fi
}

# Function to run all tests
run_all_tests() {
    print_status "Running all tests..."
    flutter test
    if [ $? -eq 0 ]; then
        print_success "All tests passed!"
    else
        print_error "Some tests failed"
        exit 1
    fi
}

# Function to generate coverage report
generate_coverage_report() {
    print_status "Generating coverage report..."
    if command -v genhtml &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        print_success "Coverage report generated in coverage/html/index.html"
    else
        print_warning "genhtml not found. Install lcov to generate HTML coverage reports."
        print_status "Coverage data available in coverage/lcov.info"
    fi
}

# Function to clean test artifacts
clean_tests() {
    print_status "Cleaning test artifacts..."
    rm -rf coverage/
    rm -rf test/.dart_tool/
    print_success "Test artifacts cleaned"
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  all                 Run all tests"
    echo "  shared              Run all shared widget tests"
    echo "  coverage            Run tests with coverage"
    echo "  report              Generate coverage report"
    echo "  clean               Clean test artifacts"
    echo "  file <path>         Run specific test file"
    echo "  help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 all                    # Run all tests"
    echo "  $0 shared                 # Run shared widget tests"
    echo "  $0 coverage               # Run tests with coverage"
    echo "  $0 file test/widgets/shared/button_test.dart"
    echo ""
}

# Main script logic
case "${1:-help}" in
    "all")
        run_all_tests
        ;;
    "shared")
        run_shared_widget_tests
        ;;
    "coverage")
        run_tests_with_coverage
        ;;
    "report")
        generate_coverage_report
        ;;
    "clean")
        clean_tests
        ;;
    "file")
        if [ -z "$2" ]; then
            print_error "Please provide a test file path"
            echo "Usage: $0 file <test_file_path>"
            exit 1
        fi
        run_test_file "$2"
        ;;
    "help"|*)
        show_help
        ;;
esac
