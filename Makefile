SHELL := /bin/bash

CC := clang
CFLAGS := -std=c99 -Wall -Wextra -Werror -O2
SRC_DIR := Sources
BUILD_DIR := build
BIN_DIR := bin
TARGET := $(BIN_DIR)/smart_home_controller

SOURCES := $(wildcard $(SRC_DIR)/*.m)
OBJECTS := $(patsubst $(SRC_DIR)/%.m,$(BUILD_DIR)/%.o,$(SOURCES))

.PHONY: all clean test

all: $(TARGET)

$(TARGET): $(OBJECTS) | $(BIN_DIR)
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.m | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)

