CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra
LDFLAGS = $(shell pkg-config --libs sdl2 SDL2_image) -lgif
CPPFLAGS = $(shell pkg-config --cflags sdl2 SDL2_image)

SRCDIR = src
OBJDIR = obj
TARGET = super_mario

SOURCES = $(wildcard $(SRCDIR)/*.cpp)
OBJECTS = $(SOURCES:$(SRCDIR)/%.cpp=$(OBJDIR)/%.o)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) -o $(TARGET) $(LDFLAGS)

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(OBJDIR)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJDIR)
	rm -f $(TARGET)

run: $(TARGET)
	./$(TARGET)

.PHONY: all clean run

