#ifndef TEST_FRAMEWORK_H
#define TEST_FRAMEWORK_H

#include <iostream>
#include <string>
#include <vector>
#include <cassert>

class TestFramework {
public:
    static int totalTests;
    static int passedTests;
    static int failedTests;
    static std::vector<std::string> failures;
    
    static void assertTrue(bool condition, const std::string& message) {
        totalTests++;
        if (condition) {
            passedTests++;
            std::cout << "✓ PASS: " << message << std::endl;
        } else {
            failedTests++;
            failures.push_back(message);
            std::cout << "✗ FAIL: " << message << std::endl;
        }
    }
    
    static void assertFalse(bool condition, const std::string& message) {
        assertTrue(!condition, message);
    }
    
    static void assertEqual(int expected, int actual, const std::string& message) {
        totalTests++;
        if (expected == actual) {
            passedTests++;
            std::cout << "✓ PASS: " << message << " (expected: " << expected << ", got: " << actual << ")" << std::endl;
        } else {
            failedTests++;
            std::string failMsg = message + " (expected: " + std::to_string(expected) + ", got: " + std::to_string(actual) + ")";
            failures.push_back(failMsg);
            std::cout << "✗ FAIL: " << failMsg << std::endl;
        }
    }
    
    static void assertEqual(float expected, float actual, float tolerance, const std::string& message) {
        totalTests++;
        float diff = (expected > actual) ? (expected - actual) : (actual - expected);
        if (diff <= tolerance) {
            passedTests++;
            std::cout << "✓ PASS: " << message << " (expected: " << expected << ", got: " << actual << ")" << std::endl;
        } else {
            failedTests++;
            std::string failMsg = message + " (expected: " + std::to_string(expected) + ", got: " + std::to_string(actual) + ")";
            failures.push_back(failMsg);
            std::cout << "✗ FAIL: " << failMsg << std::endl;
        }
    }
    
    static void assertNotNull(void* ptr, const std::string& message) {
        totalTests++;
        if (ptr != nullptr) {
            passedTests++;
            std::cout << "✓ PASS: " << message << std::endl;
        } else {
            failedTests++;
            failures.push_back(message);
            std::cout << "✗ FAIL: " << message << std::endl;
        }
    }
    
    static void assertNull(void* ptr, const std::string& message) {
        totalTests++;
        if (ptr == nullptr) {
            passedTests++;
            std::cout << "✓ PASS: " << message << std::endl;
        } else {
            failedTests++;
            failures.push_back(message);
            std::cout << "✗ FAIL: " << message << std::endl;
        }
    }
    
    static void printSummary() {
        std::cout << "\n" << std::string(50, '=') << std::endl;
        std::cout << "RÉSUMÉ DES TESTS" << std::endl;
        std::cout << std::string(50, '=') << std::endl;
        std::cout << "Total: " << totalTests << std::endl;
        std::cout << "Réussis: " << passedTests << " (" << (totalTests > 0 ? (passedTests * 100 / totalTests) : 0) << "%)" << std::endl;
        std::cout << "Échoués: " << failedTests << " (" << (totalTests > 0 ? (failedTests * 100 / totalTests) : 0) << "%)" << std::endl;
        
        if (failedTests > 0) {
            std::cout << "\nÉchecs:" << std::endl;
            for (const auto& failure : failures) {
                std::cout << "  - " << failure << std::endl;
            }
        }
        std::cout << std::string(50, '=') << std::endl;
    }
    
    static void reset() {
        totalTests = 0;
        passedTests = 0;
        failedTests = 0;
        failures.clear();
    }
};

// Initialisation des variables statiques
int TestFramework::totalTests = 0;
int TestFramework::passedTests = 0;
int TestFramework::failedTests = 0;
std::vector<std::string> TestFramework::failures;

// Macro pour les tests
#define TEST(name) void test_##name() { std::cout << "\n[" << #name << "]" << std::endl;
#define END_TEST }
#define RUN_TEST(name) test_##name();

#endif

