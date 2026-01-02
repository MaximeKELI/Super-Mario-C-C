CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -I../src -I/usr/include/SDL2
LDFLAGS = $(shell pkg-config --libs sdl2 SDL2_image)

# Fichiers de test
TEST_SOURCES = test_game_structures.cpp test_player.cpp
TEST_TARGETS = $(TEST_SOURCES:.cpp=)

# Cible par défaut
all: $(TEST_TARGETS)

# Règle pour compiler chaque test
test_game_structures: test_game_structures.cpp test_framework.h
	$(CXX) $(CXXFLAGS) -o $@ $< $(LDFLAGS)

test_player: test_player.cpp test_framework.h
	$(CXX) $(CXXFLAGS) -o $@ $< $(LDFLAGS)

# Exécuter tous les tests
test: all
	@echo "\n=== Exécution de tous les tests ==="
	@for test in $(TEST_TARGETS); do \
		echo "\n--- Exécution de $$test ---"; \
		./$$test || exit 1; \
	done
	@echo "\n=== Tous les tests terminés ==="

# Nettoyer les fichiers compilés
clean:
	rm -f $(TEST_TARGETS)

.PHONY: all test clean

