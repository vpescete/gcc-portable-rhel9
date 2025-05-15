GCC Portable Installation for RHEL 9.2
Installazione completa di GCC e dipendenze per Red Hat Enterprise Linux 9.2 senza accesso a internet (solo GitHub).

🚀 Installazione Rapida
bash
# 1. Clona questa repository
git clone https://github.com/your-username/gcc-portable-rhel9.git
cd gcc-portable-rhel9

# 2. Esegui l'installazione
chmod +x install-gcc.sh
./install-gcc.sh

# 3. Attiva l'ambiente GCC
source activate-gcc.sh

# 4. Verifica l'installazione
gcc --version
📁 Struttura della Repository
gcc-portable-rhel9/
├── README.md                 # Questo file
├── install-gcc.sh           # Script di installazione principale
├── activate-gcc.sh          # Script per attivare l'ambiente
├── binaries/                # Binari precompilati
│   ├── gcc-13.2.0-rhel9.tar.xz
│   ├── binutils-2.40.tar.xz
│   └── glibc-headers.tar.xz
├── libs/                    # Librerie essenziali
│   ├── libc6-dev-rhel9.tar.xz
│   └── linux-headers.tar.xz
└── scripts/                 # Script ausiliari
    ├── setup-environment.sh
    └── test-installation.sh
🔧 Cosa Include
GCC 13.2.0 - Compilatore C/C++ completo
Binutils - Assembler, linker, e strumenti di sviluppo
Make - Build system
Librerie di sviluppo:
glibc headers
Linux kernel headers
Librerie essenziali per C/C++
💾 Installazione Dettagliata
Prerequisiti
Accesso a GitHub (git clone)
Spazio disco: ~500MB
Permessi di scrittura nella home directory
Processo di Installazione
Download: Il clone della repo scarica tutti i binari necessari
Estrazione: Lo script estrae tutto in ~/.local/gcc/
Configurazione: Configura le variabili d'ambiente automaticamente
Directory di Installazione
Tutto viene installato in:

~/.local/gcc/
├── bin/          # Eseguibili (gcc, g++, make, etc.)
├── lib/          # Librerie
├── lib64/        # Librerie a 64-bit
├── include/      # Header files C/C++
└── libexec/      # Strumenti GCC interni
🎯 Utilizzo
Dopo l'installazione, per ogni sessione:

bash
# Attiva l'ambiente GCC
source ~/.local/gcc/activate-gcc.sh

# Ora puoi usare GCC normalmente
gcc hello.c -o hello
g++ hello.cpp -o hello
make
Rendere Permanente
Per attivare automaticamente GCC a ogni login:

bash
echo "source ~/.local/gcc/activate-gcc.sh" >> ~/.bashrc
🧪 Test di Funzionamento
bash
# Test compilazione C
echo '#include <stdio.h>
int main() { 
    printf("Hello from GCC!\\n"); 
    return 0; 
}' > test.c
gcc test.c -o test
./test

# Test compilazione C++
echo '#include <iostream>
int main() { 
    std::cout << "Hello from G++!" << std::endl; 
    return 0; 
}' > test.cpp
g++ test.cpp -o test
./test
🔍 Risoluzione Problemi
Errore: "gcc: command not found"
bash
# Assicurati di aver attivato l'ambiente
source ~/.local/gcc/activate-gcc.sh
Errore di librerie mancanti
bash
# Verifica che LD_LIBRARY_PATH sia impostato
echo $LD_LIBRARY_PATH
# Dovrebbe includere ~/.local/gcc/lib64
Problemi di permessi
bash
# Assicurati che i file siano eseguibili
chmod -R +x ~/.local/gcc/bin/
📋 Versioni Software
GCC: 13.2.0
Binutils: 2.40
Make: 4.3
Target: x86_64-redhat-linux-gnu
Compatibile con: RHEL 9.x, Rocky Linux 9.x, AlmaLinux 9.x
🤝 Contributi
Per aggiornamenti o problemi, aprire una issue su GitHub.

📝 Licenza
I binari sono distribuiti secondo le licenze originali dei rispettivi progetti:

GCC: GPL v3+
Binutils: GPL v3+
Make: GPL v3+
Nota: Questa installazione è completamente locale e non modifica il sistema. Può essere disinstallata semplicemente cancellando la directory ~/.local/gcc/.

