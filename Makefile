# Makefile di esempio per testare GCC
# Questo file dimostra come usare GCC dopo l'installazione

# Compilatore e flags
CC = gcc
CXX = g++
CFLAGS = -Wall -Wextra -O2 -std=c11
CXXFLAGS = -Wall -Wextra -O2 -std=c++17

# Directory
SRCDIR = examples
BUILDDIR = build

# Target di default
.PHONY: all clean test examples

all: examples

# Crea la directory di build
$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# Esempio C semplice
$(BUILDDIR)/hello_c: $(SRCDIR)/hello.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $< -o $@

# Esempio C++ semplice
$(BUILDDIR)/hello_cpp: $(SRCDIR)/hello.cpp | $(BUILDDIR)
	$(CXX) $(CXXFLAGS) $< -o $@

# Esempio con librerie matematiche
$(BUILDDIR)/math_example: $(SRCDIR)/math_example.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $< -lm -o $@

# Esempio C++ con STL
$(BUILDDIR)/stl_example: $(SRCDIR)/stl_example.cpp | $(BUILDDIR)
	$(CXX) $(CXXFLAGS) $< -o $@

# Compila tutti gli esempi
examples: $(BUILDDIR)/hello_c $(BUILDDIR)/hello_cpp $(BUILDDIR)/math_example $(BUILDDIR)/stl_example

# Pulisce i file compilati
clean:
	rm -rf $(BUILDDIR)

# Esegue i test
test: examples
	@echo "=== Testando gli esempi compilati ==="
	@echo "1. Hello World (C):"
	@$(BUILDDIR)/hello_c
	@echo
	@echo "2. Hello World (C++):"
	@$(BUILDDIR)/hello_cpp
	@echo
	@echo "3. Esempio matematico (C):"
	@$(BUILDDIR)/math_example
	@echo
	@echo "4. Esempio STL (C++):"
	@$(BUILDDIR)/stl_example
	@echo
	@echo "✅ Tutti i test completati con successo!"

# Mostra informazioni sul compilatore
info:
	@echo "=== Informazioni GCC ==="
	@echo "CC: $(shell which $(CC))"
	@echo "Versione CC: $(shell $(CC) --version | head -1)"
	@echo "CXX: $(shell which $(CXX))"
	@echo "Versione CXX: $(shell $(CXX) --version | head -1)"
	@echo "Make: $(shell which make)"
	@echo "Versione Make: $(shell make --version | head -1)"

# Help
help:
	@echo "Makefile per testare GCC Portable"
	@echo
	@echo "Targets disponibili:"
	@echo "  all       - Compila tutti gli esempi (default)"
	@echo "  examples  - Compila tutti gli esempi"
	@echo "  clean     - Rimuove i file compilati"
	@echo "  test      - Compila ed esegue tutti gli esempi"
	@echo "  info      - Mostra informazioni sui compilatori"
	@echo "  help      - Mostra questo messaggio"
	@echo
	@echo "Esempi individuali:"
	@echo "  $(BUILDDIR)/hello_c      - Hello World in C"
	@echo "  $(BUILDDIR)/hello_cpp    - Hello World in C++"
	@echo "  $(BUILDDIR)/math_example - Esempio con libreria math"
	@echo "  $(BUILDDIR)/stl_example  - Esempio con STL C++"