# Guide Technique Complet - Console de Jeux ESP32
## Du Novice à l'Expert : Comprendre et Réaliser Votre Projet

> **Document rédigé par un ingénieur en systèmes embarqués**
> 
> Ce guide vous accompagne de A à Z dans la compréhension et la réalisation d'une console de jeux basée sur ESP32

---

## 📚 Table des Matières

1. [Comprendre le Matériel](#1-comprendre-le-matériel)
2. [Architecture des Systèmes Embarqués](#2-architecture-des-systèmes-embarqués)
3. [La Console Arduboy - Analyse Technique](#3-la-console-arduboy)
4. [Précautions et Sécurité](#4-précautions-et-sécurité)
5. [Guide Step-by-Step Complet](#5-guide-step-by-step)
6. [Théorie des Périphériques](#6-théorie-des-périphériques)
7. [Debugging et Troubleshooting](#7-debugging-et-troubleshooting)
8. [Optimisations Avancées](#8-optimisations-avancées)
9. [Ressources et Références](#9-ressources-et-références)

---

# 1. Comprendre le Matériel

## 1.1 ESP32 : Le Microcontrôleur au Cœur du Projet

### Qu'est-ce qu'un ESP32 ?

L'ESP32 est un **System-on-Chip (SoC)** développé par Espressif Systems. C'est un microcontrôleur 32-bit extrêmement puissant qui intègre :

```
┌─────────────────────────────────────────────────────────┐
│                     ESP32 SoC                           │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   CPU Dual   │  │   WiFi       │  │  Bluetooth   │ │
│  │   Core       │  │   802.11n    │  │  BLE 4.2     │ │
│  │   Xtensa     │  │              │  │              │ │
│  │   240MHz     │  │              │  │              │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   SRAM       │  │   Flash      │  │   GPIO       │ │
│  │   520 KB     │  │   4 MB       │  │   34 pins    │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   SPI        │  │   I2C        │  │   ADC/DAC    │ │
│  │   4 bus      │  │   2 bus      │  │   Multiple   │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Spécifications Techniques Détaillées

| Caractéristique | Valeur | Explication |
|-----------------|--------|-------------|
| **Processeur** | Dual-core Xtensa LX6 | 2 cœurs indépendants à 240 MHz |
| **Architecture** | 32-bit | Peut traiter 32 bits de données par cycle |
| **SRAM** | 520 KB | Mémoire volatile (RAM) pour les variables |
| **Flash** | 4 MB (typique) | Mémoire permanente pour le programme |
| **WiFi** | 802.11 b/g/n | 2.4 GHz, jusqu'à 150 Mbps |
| **Bluetooth** | BLE 4.2 | Bluetooth Low Energy |
| **Tension** | 3.3V | **CRITIQUE : Ne jamais appliquer 5V sur les GPIO** |
| **Courant max GPIO** | 40 mA | Par pin, ne pas dépasser |
| **GPIO** | 34 pins | Dont certains sont à usage spécial |
| **ADC** | 12-bit, 18 canaux | Convertisseur analogique-numérique |
| **DAC** | 8-bit, 2 canaux | Convertisseur numérique-analogique |
| **PWM** | 16 canaux | Modulation de largeur d'impulsion |
| **Température** | -40°C à +125°C | Plage de fonctionnement |

### Pourquoi l'ESP32 pour ce Projet ?

1. **Puissance de calcul** : 240 MHz dual-core = suffisant pour émulation et jeux 2D
2. **Mémoire** : 520 KB SRAM = peut stocker plusieurs jeux en mémoire
3. **Périphériques** : SPI pour l'écran, GPIO pour les boutons
4. **Prix** : ~3-5€ = excellent rapport qualité/prix
5. **Écosystème** : Support Arduino, nombreuses bibliothèques

## 1.2 TTGO T-Display vs Heltec : Quelle Différence ?

### Important : Clarification

Vous avez mentionné avoir une **TTGO T-Display** (marque LILYGO), mais vous parlez de carte **Heltec**. Ce sont deux fabricants différents avec des cartes similaires mais non identiques.

### Comparaison Technique

| Caractéristique | TTGO T-Display | Heltec WiFi Kit 32 V3 |
|-----------------|----------------|----------------------|
| **Fabricant** | LILYGO | Heltec |
| **Écran** | TFT 1.14" (135x240) | OLED 0.96" (128x64) |
| **Type d'écran** | IPS couleur | Monochrome |
| **Contrôleur écran** | ST7789 | SSD1306 |
| **Interface écran** | SPI | I2C |
| **Boutons intégrés** | 2 (GPIO 0, 35) | 1 (PRG) |
| **Connecteur batterie** | JST 1.25mm | JST 1.25mm |
| **USB** | USB-C (T-Display) | Micro-USB / USB-C |
| **Prix** | ~10-15€ | ~15-20€ |

### Architecture de la TTGO T-Display

```
┌────────────────────────────────────────────────┐
│           TTGO T-Display Layout                │
│                                                │
│  ┌─────────────────┐                          │
│  │   Écran TFT     │  ← ST7789 Controller     │
│  │   1.14" IPS     │     240x135 pixels       │
│  │   Couleur       │     SPI Interface        │
│  └─────────────────┘                          │
│                                                │
│  [BTN1]  [BTN2]    ← GPIO 0 et GPIO 35       │
│                                                │
│  ┌──────────────────────────────────────┐    │
│  │         ESP32-PICO-D4                │    │
│  │       (4MB Flash intégré)            │    │
│  └──────────────────────────────────────┘    │
│                                                │
│  [USB-C]  [Battery JST]  [Reset BTN]         │
│                                                │
│  GPIO Header Pins (Left & Right sides)        │
└────────────────────────────────────────────────┘
```

### Brochage Critique de la TTGO T-Display

```
Écran TFT (Non modifiable - câblé en interne) :
┌──────────┬────────┬─────────────────────────────┐
│ Signal   │ GPIO   │ Description                 │
├──────────┼────────┼─────────────────────────────┤
│ TFT_MOSI │ 19     │ Master Out Slave In (SPI)   │
│ TFT_SCLK │ 18     │ Serial Clock (SPI)          │
│ TFT_CS   │ 5      │ Chip Select                 │
│ TFT_DC   │ 16     │ Data/Command                │
│ TFT_RST  │ 23     │ Reset                       │
│ TFT_BL   │ 4      │ Backlight (PWM)             │
└──────────┴────────┴─────────────────────────────┘

GPIO Libres (Disponibles pour notre projet) :
┌──────────┬────────┬─────────────────────────────┐
│ Fonction │ GPIO   │ Notes                       │
├──────────┼────────┼─────────────────────────────┤
│ BTN_UP   │ 25     │ ✅ Safe                     │
│ BTN_DOWN │ 26     │ ✅ Safe                     │
│ BTN_LEFT │ 27     │ ✅ Safe                     │
│ BTN_RIGHT│ 32     │ ✅ Safe                     │
│ BTN_A    │ 33     │ ✅ Safe                     │
│ BTN_B    │ 15     │ ✅ Safe (éviter au boot)    │
└──────────┴────────┴─────────────────────────────┘

GPIO à ÉVITER :
┌──────────┬────────┬─────────────────────────────┐
│ GPIO     │ Raison │ Conséquence                 │
├──────────┼────────┼─────────────────────────────┤
│ 0        │ Boot   │ Empêche le démarrage        │
│ 2        │ Boot   │ LED interne, perturbe boot  │
│ 12       │ Boot   │ Tension flash, critère boot │
│ 6-11     │ Flash  │ Connectés à la flash SPI    │
│ 34-39    │ Input  │ Input only, pas de pull-up  │
└──────────┴────────┴─────────────────────────────┘
```

### Schéma de Puissance

```
USB-C Input (5V)
     │
     ├──→ Régulateur 3.3V (ME6211)
     │         │
     │         ├──→ ESP32 (3.3V)
     │         ├──→ Écran TFT (3.3V)
     │         └──→ GPIO Header (3.3V)
     │
     └──→ Circuit de charge LiPo
              │
              └──→ Batterie LiPo (3.7V-4.2V)
```

## 1.3 L'Écran TFT ST7789

### Technologie de l'Écran

L'écran de la TTGO T-Display utilise la technologie **IPS (In-Plane Switching)** :

- **Résolution** : 135x240 pixels (orientation par défaut)
- **Profondeur couleur** : 16-bit (65,536 couleurs)
- **Format couleur** : RGB565 (5 bits rouge, 6 bits vert, 5 bits bleu)
- **Interface** : SPI (Serial Peripheral Interface)
- **Vitesse** : Jusqu'à 40 MHz SPI clock
- **Rétroéclairage** : LED PWM contrôlable

### Comment Fonctionne l'Affichage ?

```
Processus de Rendu d'un Pixel :

1. CPU décide de la couleur → RGB (255, 128, 64)
                                 │
2. Conversion RGB888 → RGB565    │
   R: 255 → 31 (5 bits)         │
   G: 128 → 32 (6 bits)         │
   B:  64 → 8  (5 bits)         │
                                 ▼
3. Envoi via SPI → [CS=LOW]────[DATA]────[CS=HIGH]
                        │
4. Contrôleur ST7789 → VRAM interne (135x240x16bit = 64KB)
                                 │
5. Affichage physique ←──────────┘
```

### Calcul de Performance

```
Calcul du temps pour rafraîchir tout l'écran :

Pixels totaux : 135 × 240 = 32,400 pixels
Données par pixel : 16 bits = 2 bytes
Total données : 32,400 × 2 = 64,800 bytes

À 40 MHz SPI (débit théorique maximum) :
Temps = 64,800 bytes × 8 bits / 40,000,000 Hz
      = 12.96 ms
      ≈ 77 FPS maximum théorique

En pratique (avec overhead) : ~40-60 FPS
```

---

# 2. Architecture des Systèmes Embarqués

## 2.1 Concepts Fondamentaux

### Qu'est-ce qu'un Système Embarqué ?

Un système embarqué est un **système informatique spécialisé** conçu pour accomplir des tâches spécifiques, intégré dans un dispositif plus large.

**Caractéristiques** :
- ✅ Ressources limitées (CPU, RAM, stockage)
- ✅ Fonctionnement en temps réel ou quasi-réel
- ✅ Consommation d'énergie optimisée
- ✅ Interaction avec le monde physique (capteurs, actionneurs)
- ✅ Fiabilité critique

### Architecture de Notre Console

```
┌─────────────────────────────────────────────────────────┐
│                   CONSOLE DE JEUX                       │
└─────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
   ┌─────────┐      ┌──────────┐     ┌──────────┐
   │ Entrées │      │  Calcul  │     │  Sortie  │
   │         │      │          │     │          │
   │ Boutons │─────→│   ESP32  │────→│  Écran   │
   │         │      │          │     │          │
   └─────────┘      └──────────┘     └──────────┘
                          │
                    ┌─────┴─────┐
                    ▼           ▼
              ┌─────────┐ ┌─────────┐
              │  Flash  │ │  SRAM   │
              │ (Code)  │ │ (Data)  │
              └─────────┘ └─────────┘
```

### Boucle de Jeu (Game Loop)

```cpp
void loop() {
    // 1. ENTRÉES : Lire l'état des boutons
    readButtons();
    
    // 2. TRAITEMENT : Mettre à jour la logique du jeu
    updateGameLogic();
    
    // 3. SORTIE : Afficher le résultat
    renderGraphics();
    
    // 4. TIMING : Maintenir 60 FPS
    delay(16); // ~16ms = 60 FPS
}
```

### Cycle d'Exécution Détaillé

```
Temps ────────────────────────────────────────────────────→

Frame 1 (16.67ms @ 60 FPS)
├─ Input (1ms)     : Lecture des GPIO, debounce
├─ Update (8ms)    : Physique, collisions, IA
├─ Render (6ms)    : Dessiner sur l'écran
└─ Wait (1.67ms)   : Attendre le prochain frame

Frame 2 (16.67ms @ 60 FPS)
├─ Input (1ms)
├─ Update (8ms)
├─ Render (6ms)
└─ Wait (1.67ms)

... et ainsi de suite
```

## 2.2 Gestion de la Mémoire

### Organisation de la Mémoire ESP32

```
┌─────────────────────────────────────────────────┐
│             Carte Mémoire ESP32                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  FLASH (4 MB) - Non-volatile                   │
│  ┌───────────────────────────────────────────┐ │
│  │ 0x000000  Bootloader (32 KB)              │ │
│  │ 0x008000  Partition Table (4 KB)          │ │
│  │ 0x010000  Application (1.3 MB)            │ │
│  │           ↳ Votre code compilé            │ │
│  │ 0x150000  OTA Update (1.3 MB)             │ │
│  │ 0x290000  SPIFFS / Storage (1.4 MB)       │ │
│  │           ↳ Fichiers, data                │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  SRAM (520 KB) - Volatile (perdue au reset)    │
│  ┌───────────────────────────────────────────┐ │
│  │ 0x3FF80000  ROM (448 KB)                  │ │
│  │             ↳ Bootloader, WiFi, BT        │ │
│  │ 0x3FFB0000  DRAM (320 KB)                 │ │
│  │             ↳ Variables globales           │ │
│  │             ↳ Heap (malloc)               │ │
│  │             ↳ Stack                       │ │
│  │ 0x40000000  IRAM (200 KB)                 │ │
│  │             ↳ Code critique                │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  RTC Memory (8 KB) - Survit au deep sleep     │
│  ┌───────────────────────────────────────────┐ │
│  │ Variables pour wake-up                    │ │
│  └───────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Allocation Mémoire dans Notre Jeu

```cpp
// FLASH (mémoire programme)
const uint8_t spriteData[] = { /* ... */ };  // Stocké en Flash

// SRAM - Variables globales
int score = 0;              // ~4 bytes
float playerX = 120.0;      // ~4 bytes
TFT_eSPI tft;               // ~100 bytes (structure)

// SRAM - Heap (allocation dynamique)
Game* currentGame = new Game();  // malloc() automatique

// Stack (pile d'exécution)
void myFunction() {
    int localVar = 42;      // Sur le stack
    // Détruit automatiquement en sortant de fonction
}
```

### Règles d'Or de Gestion Mémoire

1. **Minimiser les allocations dynamiques** (`new`, `malloc`)
   - Préférer les tableaux statiques
   - Réutiliser les buffers

2. **Attention aux fuites mémoire**
   ```cpp
   // ❌ MAUVAIS
   void loop() {
       Game* game = new Game();  // Fuite !
       // ... pas de delete
   }
   
   // ✅ BON
   Game* game = nullptr;
   void setup() {
       game = new Game();
   }
   void cleanup() {
       delete game;
   }
   ```

3. **Utiliser PROGMEM pour les données constantes**
   ```cpp
   // ❌ MAUVAIS (consomme SRAM)
   const char text[] = "Hello World";
   
   // ✅ BON (reste en Flash)
   const char text[] PROGMEM = "Hello World";
   ```

## 2.3 Communication SPI (Serial Peripheral Interface)

### Qu'est-ce que SPI ?

SPI est un **protocole de communication synchrone** entre un maître et un ou plusieurs esclaves.

```
Maître (ESP32)              Esclave (Écran ST7789)
┌──────────┐                ┌──────────┐
│          │    SCLK        │          │
│          │───────────────→│          │
│          │    MOSI        │          │
│          │───────────────→│          │
│          │    MISO        │          │
│          │←───────────────│          │
│          │    CS          │          │
│          │───────────────→│          │
└──────────┘                └──────────┘
```

**Signaux SPI** :
- **SCLK** (Serial Clock) : Horloge générée par le maître
- **MOSI** (Master Out Slave In) : Données du maître vers l'esclave
- **MISO** (Master In Slave Out) : Données de l'esclave vers le maître
- **CS** (Chip Select) : Sélection de l'esclave (actif bas)

### Chronogramme SPI

```
Temps ───────────────────────────────────────────────────→

CS   ──┐     ┌─────────────────────────────────────┐     ┌──
       └─────┘                                     └─────┘
       
SCLK ────┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐
         └┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘
         
MOSI ────<B7><B6><B5><B4><B3><B2><B1><B0>──────────────────
         │MSB                       LSB│
         └──────── 1 Byte ─────────────┘

Explication :
1. CS passe à LOW → Début de communication
2. SCLK génère des impulsions
3. MOSI envoie les bits synchronisés avec SCLK
4. CS repasse à HIGH → Fin de communication
```

### Configuration SPI pour ST7789

```cpp
// Paramètres SPI pour l'écran
SPISettings spiSettings(
    40000000,          // Fréquence : 40 MHz
    MSBFIRST,          // Bit de poids fort en premier
    SPI_MODE0          // Clock polarity & phase
);

// Modes SPI :
// Mode 0 : CPOL=0, CPHA=0 (le plus courant)
// Mode 1 : CPOL=0, CPHA=1
// Mode 2 : CPOL=1, CPHA=0
// Mode 3 : CPOL=1, CPHA=1
```

---

# 3. La Console Arduboy - Analyse Technique

## 3.1 Qu'est-ce que l'Arduboy ?

L'**Arduboy** est une console de jeux open-source basée sur Arduino, créée en 2014.

### Spécifications Arduboy Original

```
┌────────────────────────────────────────────────┐
│             Arduboy Original                   │
├────────────────────────────────────────────────┤
│ Microcontrôleur : ATmega32u4 @ 16 MHz         │
│ RAM            : 2.5 KB                        │
│ Flash          : 32 KB                         │
│ EEPROM         : 1 KB                          │
│ Écran          : OLED 128x64 monochrome        │
│ Boutons        : 6 (D-Pad + A + B)             │
│ Son            : Buzzer piezo                  │
│ Batterie       : LiPo 180 mAh                  │
│ Autonomie      : 8 heures                      │
│ Dimensions     : Format Game Boy Pocket        │
└────────────────────────────────────────────────┘
```

### Architecture Matérielle Arduboy

```
                    ┌────────────────┐
                    │  ATmega32u4    │
                    │  16 MHz        │
                    └────────┬───────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
    ┌────▼────┐         ┌────▼────┐        ┌────▼────┐
    │  OLED   │         │ Buttons │        │ Speaker │
    │ SSD1306 │         │  GPIO   │        │  PWM    │
    │  I2C    │         │         │        │         │
    └─────────┘         └─────────┘        └─────────┘
```

## 3.2 Comparaison Arduboy vs Notre Console TTGO

| Caractéristique | Arduboy | Notre Console TTGO | Ratio |
|-----------------|---------|-------------------|-------|
| **CPU** | 16 MHz | 240 MHz × 2 | **30× plus rapide** |
| **RAM** | 2.5 KB | 520 KB | **208× plus** |
| **Flash** | 32 KB | 4 MB | **128× plus** |
| **Écran** | 128×64 mono | 240×135 couleur | **4× pixels, couleur** |
| **Résolution** | 8,192 px | 32,400 px | **4× plus** |

### Pourquoi Cette Différence est Importante ?

```
Ce qu'on peut faire avec Arduboy :
✅ Jeux 2D simples en noir et blanc
✅ ~10 sprites à l'écran
✅ Musique monophonique simple
✅ Physique basique

Ce qu'on peut faire avec ESP32 :
✅ Jeux 2D complexes en couleur
✅ 100+ sprites à l'écran
✅ Musique polyphonique
✅ Physique avancée
✅ IA plus intelligente
✅ Graphismes plus détaillés
✅ WiFi/Bluetooth (multijoueur)
```

## 3.3 Format des Jeux Arduboy (.hex)

### Structure d'un Fichier .hex

Les jeux Arduboy sont distribués en fichiers **.hex** (Intel HEX format).

```
:10000000C0E0D0E00CC18BC100C10AC109C108C194
││││││││└─ Checksum
│││││││└─── Données (16 bytes max)
││││││└──── Type (00 = data, 01 = EOF)
│││││└───── Adresse (2 bytes)
││││└────── Nombre de bytes de données
│││└─────── Toujours ':'
└──────────┘

Explication ligne par ligne :
:10 0000 00 [16 bytes de données] [checksum]
 │   │   │
 │   │   └─ Record type (00 = Data)
 │   └───── Adresse de chargement (0x0000)
 └───────── Nombre de bytes (0x10 = 16)
```

### Exemple Concret

```hex
:020000040000FA     ← Extended Address (segment)
:10000000C0E0D0E00CC18BC100C10AC109C108C194  ← Code
:10001000078106C105C104C103C102C101C10FC0AE  ← Code
:00000001FF     ← End Of File
```

Ce code représente :
1. Les **instructions machine AVR** compilées
2. À charger à l'**adresse 0x0000** (début du programme)
3. Exécutables par le **ATmega32u4**

### Pourquoi On Ne Peut Pas Juste Exécuter un .hex sur ESP32 ?

```
Fichier .hex Arduboy
       │
       ├─ Instructions machine AVR (RISC)
       │  Exemple : LDI R16, 0xFF
       │            (Load Immediate dans registre R16)
       │
       └─ Architecture 8-bit AVR
          ┌────────────────┐
          │  ATmega32u4    │
          │  8-bit RISC    │
          │  Harvard Arch  │
          └────────────────┘

VS

ESP32
┌────────────────┐
│  Xtensa LX6    │
│  32-bit CISC   │
│  Von Neumann   │
└────────────────┘
       │
       └─ Instructions machine Xtensa
          Exemple : MOVI A2, 0xFF
                   (Move Immediate dans registre A2)

❌ Incompatibles ! Architectures différentes
```

### Solution 1 : Émulateur AVR

Pour exécuter les .hex, il faut un **émulateur AVR** qui :

```
1. Lit le fichier .hex
      │
2. Parse les instructions AVR
      │
3. Simule l'exécution sur ESP32
      │
      ├─ Émule les registres AVR (R0-R31)
      ├─ Émule la mémoire AVR
      ├─ Émule les périphériques (GPIO, SPI, etc.)
      └─ Traduit les affichages OLED → TFT
```

**Complexité** : Très élevée (projet de plusieurs mois)

### Solution 2 : Recompilation (Notre Approche)

```
Code Source Arduboy (C++)
       │
       ├─ Adapter pour ESP32
       │  - Changer bibliothèques
       │  - Ajuster résolution
       │
       └─ Compiler pour ESP32
              │
              └─→ Code machine Xtensa
                  (natif, performances maximales)
```

**Avantage** : Performances natives, pas d'émulation

**Inconvénient** : Il faut le code source (pas juste le .hex)

---

# 4. Précautions et Sécurité

## 4.1 Sécurité Électrique

### ⚠️ RÈGLES CRITIQUES - À NE JAMAIS ENFREINDRE

```
┌─────────────────────────────────────────────────┐
│            🚨 DANGER - 3.3V LOGIC 🚨           │
├─────────────────────────────────────────────────┤
│                                                 │
│  ESP32 fonctionne en LOGIQUE 3.3V              │
│                                                 │
│  ❌ INTERDICTIONS ABSOLUES :                    │
│                                                 │
│  1. ❌ Ne JAMAIS appliquer 5V sur un GPIO      │
│     → Destruction immédiate du pin             │
│     → Peut détruire tout l'ESP32               │
│                                                 │
│  2. ❌ Ne JAMAIS dépasser 40mA par GPIO        │
│     → Surchauffe                               │
│     → Dégradation permanente                   │
│                                                 │
│  3. ❌ Ne JAMAIS court-circuiter GPIO → GND    │
│     → Courant illimité                         │
│     → Destruction garantie                     │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Tensions Sûres

```
Plage de Tension par Type de Pin :

GPIO Standard (Input/Output)
    ┌──────────────────────────────┐
    │  0V (GND)        3.3V (HIGH) │
    │   │               │          │
    └───┴───────────────┴──────────┘
        Safe Zone
    
    ⚠️ >3.6V = DANGER
    ❌ >4V = DESTRUCTION

GPIO Input-Only (34-39)
    ┌──────────────────────────────┐
    │  0V (GND)        3.3V (HIGH) │
    │   │               │          │
    └───┴───────────────┴──────────┘
        Safe Zone
    
    ℹ️ Ces GPIO n'ont pas de pull-up interne
    ℹ️ Ne peuvent PAS être configurés en OUTPUT

Alimentation Générale
    ┌──────────────────────────────┐
    │  USB: 5V ─→ Régulateur ─→ 3.3V │
    │  Battery: 3.7V ─→ 3.3V       │
    └──────────────────────────────┘
```

### Connexion Sécurisée des Boutons

```
Méthode 1 : Pull-up Interne (RECOMMANDÉE)
┌──────────────────────────────────────┐
│                                      │
│  3.3V ──[Pull-up Interne 45kΩ]      │
│                 │                    │
│           GPIO ─┼─── [Bouton] ── GND │
│                                      │
└──────────────────────────────────────┘

Avantages :
✅ Pas de résistance externe nécessaire
✅ Simplifie le câblage
✅ Configuration logicielle

Code :
pinMode(BTN_PIN, INPUT_PULLUP);


Méthode 2 : Pull-up Externe
┌──────────────────────────────────────┐
│                                      │
│  3.3V ──[10kΩ]───┬─── GPIO          │
│                  │                   │
│           [Bouton] ── GND            │
│                                      │
└──────────────────────────────────────┘

Avantages :
✅ Plus stable
✅ Résistance personnalisable
✅ Moins sensible aux interférences


⚠️ JAMAIS COMME ÇA (Pull-down sur ESP32) :
┌──────────────────────────────────────┐
│                                      │
│  3.3V ── [Bouton] ──┬─── GPIO       │
│                     │                │
│                  [10kΩ] ── GND      │
│                                      │
└──────────────────────────────────────┘

❌ Risque de court-circuit si GPIO mal configuré
```

### Protection Contre les Surtensions

```
Si vous devez interfacer avec du 5V (Arduino, etc.) :

Solution : Diviseur de tension
┌────────────────────────────────────┐
│                                    │
│  5V Signal ──[10kΩ]──┬── GPIO     │
│                      │             │
│                   [20kΩ]           │
│                      │             │
│                     GND            │
│                                    │
└────────────────────────────────────┘

Calcul : Vout = Vin × R2/(R1+R2)
        Vout = 5V × 20kΩ/(10kΩ+20kΩ)
        Vout = 5V × 0.667 = 3.33V ✅
```

## 4.2 Précautions de Manipulation

### Électricité Statique (ESD)

```
┌─────────────────────────────────────────────┐
│      Décharge Électrostatique (ESD)        │
├─────────────────────────────────────────────┤
│                                             │
│  Le corps humain peut accumuler jusqu'à    │
│  35,000 Volts d'électricité statique !     │
│                                             │
│  Seuils de dommage pour l'ESP32 :          │
│  • 100V : Dommage possible                 │
│  • 1000V : Dommage garanti                 │
│                                             │
│  ⚡ Vous ne sentez la décharge qu'à         │
│     partir de 3000V                        │
│  ⚡ Donc vous pouvez détruire sans sentir ! │
│                                             │
└─────────────────────────────────────────────┘
```

**Protection ESD** :

1. **Bracelet antistatique**
   ```
   Vous ──[Bracelet]──[1MΩ]── Terre (GND)
         Protection          Résistance
   ```

2. **Toucher du métal mis à la terre** avant manipulation

3. **Travailler sur tapis antistatique**

4. **Éviter les vêtements synthétiques** (génèrent de l'électricité statique)

### Soudure (si nécessaire)

```
Température du fer à souder :
┌────────────────────────────────────┐
│  300-350°C : ✅ Optimal            │
│  250-300°C : ⚠️ Trop froid         │
│  350-400°C : ⚠️ Trop chaud         │
│  >400°C    : ❌ Dommage certain    │
└────────────────────────────────────┘

Temps de contact :
┌────────────────────────────────────┐
│  1-2 secondes : ✅ Parfait         │
│  3-4 secondes : ⚠️ Acceptable      │
│  >5 secondes  : ❌ Trop long       │
└────────────────────────────────────┘
```

## 4.3 Environnement de Travail

### Espace de Travail Idéal

```
┌────────────────────────────────────────────┐
│          Poste de Travail Optimal          │
├────────────────────────────────────────────┤
│                                            │
│  🔦 Éclairage                              │
│     └─ Lumière blanche, 500+ lux          │
│                                            │
│  🪑 Chaise confortable                     │
│     └─ Hauteur ajustable                  │
│                                            │
│  📏 Table propre et dégagée               │
│     └─ Surface non conductrice            │
│                                            │
│  🔌 Alimentation stable                    │
│     └─ Multiprise avec parafoudre         │
│                                            │
│  🧰 Outils organisés                       │
│     ├─ Multimètre                         │
│     ├─ Pinces                             │
│     ├─ Tournevis                          │
│     └─ Câbles de test                     │
│                                            │
│  🗑️ Poubelle à proximité                  │
│                                            │
└────────────────────────────────────────────┘
```

### Conditions Environnementales

```
Température : 15°C - 25°C (optimal)
Humidité    : 40% - 60% (évite ESD)
Ventilation : Bonne (si soudure)
```

---

# 5. Guide Step-by-Step Complet

## ÉTAPE 0 : Préparation et Vérification

### Checklist Matériel

```
□ TTGO T-Display (ou Heltec équivalent)
□ 6 boutons tactiles (push buttons, normalement ouverts)
□ Câbles jumper (mâle-mâle, 20 minimum)
□ Breadboard (facultatif mais recommandé)
□ Câble USB-C (pour TTGO)
□ Ordinateur (Windows/Mac/Linux)
□ Multimètre (fortement recommandé)
```

### Vérification Initiale de la Carte

#### Test 1 : Alimentation

```cpp
// Sketch de test minimal
void setup() {
  pinMode(2, OUTPUT);  // LED interne (si présente)
}

void loop() {
  digitalWrite(2, HIGH);
  delay(500);
  digitalWrite(2, LOW);
  delay(500);
}
```

**Résultat attendu** : LED clignote → Carte fonctionne

#### Test 2 : Écran

```cpp
#include <TFT_eSPI.h>

TFT_eSPI tft = TFT_eSPI();

void setup() {
  tft.init();
  tft.fillScreen(TFT_RED);
  delay(1000);
  tft.fillScreen(TFT_GREEN);
  delay(1000);
  tft.fillScreen(TFT_BLUE);
}

void loop() {}
```

**Résultat attendu** : Écran affiche rouge, vert, puis bleu

---

## ÉTAPE 1 : Installation de l'Environnement de Développement

### 1.1 Installation d'Arduino IDE

```
Windows :
1. Télécharger : https://www.arduino.cc/en/software
2. Exécuter l'installeur
3. Accepter les drivers

macOS :
1. Télécharger le .dmg
2. Glisser dans Applications
3. Autoriser dans Préférences Système → Sécurité

Linux (Ubuntu/Debian) :
sudo apt update
sudo apt install arduino
# Ou télécharger depuis arduino.cc
```

### 1.2 Configuration du Support ESP32

**Méthode détaillée** :

1. **Ouvrir Arduino IDE**

2. **Ajouter l'URL du gestionnaire de cartes** :
   - `Fichier` → `Préférences`
   - Champ "URLs de gestionnaire de cartes supplémentaires"
   - Ajouter :
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
   - Si d'autres URLs existent, séparer par des virgules

3. **Installer le package ESP32** :
   - `Outils` → `Type de carte` → `Gestionnaire de cartes`
   - Rechercher "esp32"
   - Installer "esp32 by Espressif Systems"
   - Version recommandée : **2.0.11** ou supérieure
   - Temps d'installation : ~5-10 minutes (télécharge ~250 MB)

4. **Sélectionner la carte** :
   - `Outils` → `Type de carte` → `ESP32 Arduino`
   - Choisir **"ESP32 Dev Module"**

5. **Configurer les paramètres** :
   ```
   Outils menu :
   ├─ Upload Speed : 921600
   ├─ CPU Frequency : 240MHz (WiFi/BT)
   ├─ Flash Frequency : 80MHz
   ├─ Flash Mode : QIO
   ├─ Flash Size : 4MB (32Mb)
   ├─ Partition Scheme : Default 4MB
   ├─ Core Debug Level : None
   └─ PSRAM : Disabled
   ```

### 1.3 Installation de TFT_eSPI

**Installation** :
1. `Outils` → `Gérer les bibliothèques`
2. Rechercher "TFT_eSPI"
3. Installer **TFT_eSPI by Bodmer**
4. Version recommandée : **2.5.0+**

**Configuration critique** :

Localiser le fichier :
```
Windows : 
C:\Users\[Votre_Nom]\Documents\Arduino\libraries\TFT_eSPI\User_Setup_Select.h

macOS :
/Users/[Votre_Nom]/Documents/Arduino/libraries/TFT_eSPI/User_Setup_Select.h

Linux :
~/Arduino/libraries/TFT_eSPI/User_Setup_Select.h
```

Éditer avec un éditeur de texte :

```cpp
// Ligne ~22 : COMMENTER cette ligne
// #include <User_Setup.h>  // ← Ajouter "//" devant

// Ligne ~53 : DÉCOMMENTER cette ligne
#include <User_Setups/Setup25_TTGO_T_Display.h>  // ← Enlever "//"
```

**Vérification** :
```cpp
// Test de configuration
#include <TFT_eSPI.h>

TFT_eSPI tft = TFT_eSPI();

void setup() {
  Serial.begin(115200);
  
  tft.init();
  tft.setRotation(1);
  
  Serial.print("TFT Width: ");
  Serial.println(tft.width());   // Devrait afficher 240
  Serial.print("TFT Height: ");
  Serial.println(tft.height());  // Devrait afficher 135
  
  tft.fillScreen(TFT_GREEN);
  tft.setTextColor(TFT_BLACK);
  tft.setTextSize(2);
  tft.setCursor(50, 60);
  tft.print("CONFIG OK!");
}

void loop() {}
```

---

## ÉTAPE 2 : Câblage des Boutons

### 2.1 Schéma de Principe

```
Vue d'ensemble du câblage :

TTGO T-Display
┌────────────────────────────────────┐
│                                    │
│  [GPIO 25] ─────────┐              │
│  [GPIO 26] ─────────┤              │
│  [GPIO 27] ─────────┤              │
│  [GPIO 32] ─────────┼─────→ Boutons│
│  [GPIO 33] ─────────┤              │
│  [GPIO 15] ─────────┤              │
│  [GND]     ─────────┘              │
│                                    │
└────────────────────────────────────┘
```

### 2.2 Câblage Physique Détaillé

#### Option A : Sans Breadboard (Direct)

```
Bouton UP :
┌──────────────────────────────────┐
│                                  │
│  GPIO 25 ──── [Bouton] ──── GND │
│                                  │
└──────────────────────────────────┘

Répéter pour chaque bouton avec son GPIO respectif
```

**Procédure** :

1. **Identifier les pattes du bouton**
   ```
   Vue du dessus d'un bouton tactile :
   
   ┌─────────────┐
   │  1       2  │  ← Normalement connectés ensemble
   │             │
   │  3       4  │  ← Normalement connectés ensemble
   └─────────────┘
   
   Appuyé : 1-3 et 2-4 sont connectés
   ```

2. **Connexion du premier bouton (UP)** :
   - Patte 1 du bouton → GPIO 25
   - Patte 3 du bouton → GND
   - Pattes 2 et 4 : non utilisées

3. **Répéter pour les 5 autres boutons** :
   - DOWN : GPIO 26 → [Bouton] → GND
   - LEFT : GPIO 27 → [Bouton] → GND
   - RIGHT : GPIO 32 → [Bouton] → GND
   - A : GPIO 33 → [Bouton] → GND
   - B : GPIO 15 → [Bouton] → GND

#### Option B : Avec Breadboard (Recommandé)

```
Schéma breadboard :

Breadboard
┌────────────────────────────────────────────────────┐
│ + Rail (rouge)  : Non utilisé                     │
│ - Rail (bleu)   : Connecté au GND de la TTGO     │
├────────────────────────────────────────────────────┤
│                                                    │
│  [BTN_UP]    [BTN_DOWN]  [BTN_LEFT]              │
│     │             │           │                    │
│  GPIO25       GPIO26      GPIO27                  │
│     │             │           │                    │
│     └─────────────┴───────────┴──→ Tous vers GND  │
│                                                    │
│  [BTN_RIGHT] [BTN_A]     [BTN_B]                  │
│     │             │           │                    │
│  GPIO32       GPIO33      GPIO15                  │
│     │             │           │                    │
│     └─────────────┴───────────┴──→ Tous vers GND  │
│                                                    │
└────────────────────────────────────────────────────┘
```

**Avantages du breadboard** :
- ✅ Plus facile à modifier
- ✅ Pas de soudure nécessaire
- ✅ Rail GND commun
- ✅ Prototypage rapide

### 2.3 Test des Boutons

```cpp
// Programme de test des boutons
#include <TFT_eSPI.h>

TFT_eSPI tft = TFT_eSPI();

#define BTN_UP     25
#define BTN_DOWN   26
#define BTN_LEFT   27
#define BTN_RIGHT  32
#define BTN_A      33
#define BTN_B      15

void setup() {
  Serial.begin(115200);
  
  // Configuration des boutons
  pinMode(BTN_UP, INPUT_PULLUP);
  pinMode(BTN_DOWN, INPUT_PULLUP);
  pinMode(BTN_LEFT, INPUT_PULLUP);
  pinMode(BTN_RIGHT, INPUT_PULLUP);
  pinMode(BTN_A, INPUT_PULLUP);
  pinMode(BTN_B, INPUT_PULLUP);
  
  // Écran
  tft.init();
  tft.setRotation(1);
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_WHITE);
  tft.setTextSize(2);
  tft.setCursor(20, 10);
  tft.print("Test Boutons");
}

void loop() {
  tft.fillRect(0, 40, 240, 95, TFT_BLACK);  // Effacer zone de texte
  
  int y = 45;
  tft.setCursor(10, y);
  
  // Tester chaque bouton
  if (!digitalRead(BTN_UP)) {
    tft.setTextColor(TFT_GREEN);
    tft.print("UP PRESSED");
    Serial.println("UP");
  }
  
  y += 15;
  tft.setCursor(10, y);
  if (!digitalRead(BTN_DOWN)) {
    tft.setTextColor(TFT_GREEN);
    tft.print("DOWN PRESSED");
    Serial.println("DOWN");
  }
  
  y += 15;
  tft.setCursor(10, y);
  if (!digitalRead(BTN_LEFT)) {
    tft.setTextColor(TFT_GREEN);
    tft.print("LEFT PRESSED");
    Serial.println("LEFT");
  }
  
  y += 15;
  tft.setCursor(10, y);
  if (!digitalRead(BTN_RIGHT)) {
    tft.setTextColor(TFT_GREEN);
    tft.print("RIGHT PRESSED");
    Serial.println("RIGHT");
  }
  
  y += 15;
  tft.setCursor(10, y);
  if (!digitalRead(BTN_A)) {
    tft.setTextColor(TFT_GREEN);
    tft.print("A PRESSED");
    Serial.println("A");
  }
  
  y += 15;
  tft.setCursor(10, y);
  if (!digitalRead(BTN_B)) {
    tft.setTextColor(TFT_GREEN);
    tft.print("B PRESSED");
    Serial.println("B");
  }
  
  delay(50);
}
```

**Tests à effectuer** :
1. Uploadez le programme
2. Ouvrez le moniteur série (115200 baud)
3. Appuyez sur chaque bouton un par un
4. Vérifiez que le nom du bouton s'affiche à l'écran ET dans le serial

**Problèmes courants** :

| Symptôme | Cause | Solution |
|----------|-------|----------|
| Rien ne s'affiche | Mauvaise connexion | Vérifier le câblage |
| Affiche tout le temps | Bouton inversé | Vérifier INPUT_PULLUP |
| Plusieurs boutons à la fois | Court-circuit | Isoler les connexions |
| Valeur aléatoire | Pas de pull-up | Ajouter INPUT_PULLUP |

---

## ÉTAPE 3 : Upload du Système de Jeux

### 3.1 Préparation des Fichiers

1. **Créer le dossier projet** :
   ```
   Documents/Arduino/TTGO_Arcade/
   ```

2. **Placer tous les fichiers** dans ce dossier :
   ```
   TTGO_Arcade/
   ├── TTGO_Arcade.ino
   ├── Game.h
   ├── SnakeGame.h
   ├── FlappyGame.h
   ├── PongGame.h
   ├── BreakoutGame.h
   ├── SpaceInvadersGame.h
   ├── TetrisGame.h
   ├── RacingGame.h
   ├── DinoRunGame.h
   ├── MazeGame.h
   └── ShooterGame.h
   ```

   **IMPORTANT** : Le dossier DOIT avoir le même nom que le fichier .ino

### 3.2 Vérification du Code

1. **Ouvrir** `TTGO_Arcade.ino`

2. **Vérifier les GPIO** en haut du fichier :
   ```cpp
   #define BTN_UP     25
   #define BTN_DOWN   26
   #define BTN_LEFT   27
   #define BTN_RIGHT  32
   #define BTN_A      33
   #define BTN_B      15
   ```
   Ajuster si vous avez utilisé d'autres GPIO

3. **Cliquer sur "Vérifier"** (✓) :
   - Arduino compile le code
   - Temps : ~30-60 secondes
   - Messages en bas de l'écran

**Messages normaux** :
```
Compilation des bibliothèques...
Compilation du croquis...
"TTGO_Arcade.ino.elf" section `.iram0.text' will not fit
Le croquis utilise 847392 octets (64%) de l'espace de stockage
Les variables globales utilisent 38564 octets (11%) de mémoire dynamique
```

**Erreurs courantes** :

```
Erreur : "Game.h: No such file or directory"
→ Tous les fichiers .h doivent être dans le même dossier

Erreur : "TFT_eSPI.h: No such file or directory"
→ Bibliothèque TFT_eSPI pas installée

Erreur : "User_Setup_Select.h:39:26: error..."
→ Configuration TFT_eSPI incorrecte
```

### 3.3 Upload du Programme

1. **Connecter la TTGO** via USB-C

2. **Sélectionner le port** :
   - Windows : COM3, COM4, etc.
   - macOS : /dev/cu.usbserial-XXXXX
   - Linux : /dev/ttyUSB0, /dev/ttyACM0

3. **Cliquer sur "Téléverser"** (→)

4. **Attendre l'upload** :
   ```
   Écriture à 0x00001000... (1%)
   Écriture à 0x00002000... (2%)
   ...
   Écriture à 0x000d0000... (100%)
   Quitter...
   ```
   Temps : ~20-30 secondes

**Si l'upload échoue** :

```
Méthode 1 : Mode BOOT Manuel
1. Maintenir le bouton BOOT sur la TTGO
2. Cliquer sur Upload
3. Attendre "Connecting..."
4. Relâcher BOOT
5. Upload démarre

Méthode 2 : Réduire la vitesse
Outils → Upload Speed → 115200
(Au lieu de 921600)

Méthode 3 : Changer de câble USB
Certains câbles sont charge-only
```

### 3.4 Premier Démarrage

**Séquence de démarrage normale** :

```
1. Écran noir (1 sec)
   ↓
2. "TTGO ARCADE" en cyan (1 sec)
   ↓
3. Barre de chargement verte (1 sec)
   ↓
4. Menu avec liste de jeux
   ↓
5. Indicateur animé ► sur le premier jeu
```

**Test rapide** :
1. Appuyer DOWN → Sélection descend
2. Appuyer UP → Sélection monte
3. Appuyer A → Jeu se lance
4. Maintenir B (1 sec) → Retour au menu

---

## ÉTAPE 4 : Jouer et Comprendre

### 4.1 Navigation dans le Menu

```
Menu Structure :

┌────────────────────────────────────┐
│  ARCADE                            │  ← Header
├────────────────────────────────────┤
│  Choisis ton jeu:                  │
│                                    │
│  ► SNAKE                          │  ← Sélection actuelle
│    FLAPPY BIRD                    │
│    PONG                           │
│    BREAKOUT                       │
│    SPACE INVADERS                 │
│                                    │
│  UP/DOWN:Select  A:Play           │  ← Instructions
└────────────────────────────────────┘

Contrôles :
• UP/DOWN : Naviguer (avec auto-scroll)
• A : Lancer le jeu sélectionné
• Indicateur ► clignote
```

### 4.2 Mécaniques de Chaque Jeu

#### SNAKE (Jeu 1)
```
Objectif : Manger les pommes rouges sans se mordre

Contrôles :
• UP/DOWN/LEFT/RIGHT : Diriger le serpent
• Pas de pause

Mécanique :
1. Serpent se déplace automatiquement
2. Mange pomme → +10 points, grandit
3. Touche mur ou corps → Game Over

Stratégie :
• Planifier le chemin à l'avance
• Ne pas se coincer dans un coin
• Vitesse augmente avec le score
```

#### FLAPPY BIRD (Jeu 2)
```
Objectif : Passer entre les tuyaux

Contrôles :
• A : Battre des ailes (sauter)

Mécanique :
1. Gravité tire l'oiseau vers le bas
2. A applique une impulsion vers le haut
3. Touche tuyau ou sol → Game Over

Stratégie :
• Timing des sauts crucial
• Viser le milieu de l'espace
• Petit tap = petit saut
```

#### PONG (Jeu 3)
```
Objectif : Marquer 5 points contre l'IA

Contrôles :
• UP/DOWN : Déplacer la raquette

Mécanique :
1. Balle rebondit sur les raquettes
2. Angle de rebond = position d'impact
3. Premier à 5 points gagne

Stratégie :
• Frapper avec le bord → angle prononcé
• Frapper au centre → angle droit
• L'IA suit la balle
```

### 4.3 Comprendre le Code

**Structure d'un jeu** :

```cpp
class MonJeu : public Game {
    // DONNÉES
    private:
        int playerX, playerY;     // Position du joueur
        int enemyX, enemyY;       // Position d'un ennemi
        bool gameStarted;         // État du jeu
    
    // INITIALISATION
    public:
        void init() override {
            // Appelé au démarrage du jeu
            playerX = 120;
            playerY = 100;
            score = 0;
            gameOver = false;
        }
    
    // LOGIQUE (60 fois par seconde)
    void update(bool up, bool down, bool left, 
                bool right, bool a, bool b) override {
        // 1. Traiter les entrées
        if (left) playerX -= 3;
        if (right) playerX += 3;
        
        // 2. Mettre à jour la physique
        enemyY += 2;  // Ennemi descend
        
        // 3. Vérifier les collisions
        if (collision(playerX, playerY, enemyX, enemyY)) {
            gameOver = true;
        }
        
        // 4. Afficher
        render();
    }
    
    // AFFICHAGE
    void render() override {
        // Effacer
        tft->fillScreen(TFT_BLACK);
        
        // Dessiner le joueur
        tft->fillRect(playerX, playerY, 16, 16, TFT_CYAN);
        
        // Dessiner l'ennemi
        tft->fillRect(enemyX, enemyY, 16, 16, TFT_RED);
        
        // Afficher le score
        displayScore();
    }
};
```

**Cycle de vie d'un jeu** :

```
Menu
 │
 ├─ Utilisateur appuie sur A
 │
 ▼
launchGame(index)
 │
 ├─ new MonJeu(&tft)
 ├─ game->init()
 │
 ▼
loop() {
    handleGame()
     │
     ├─ readButtons()
     ├─ game->update(...)
     └─ Vérifier gameOver
}
 │
 ├─ Si gameOver
 │
 ▼
showGameOver()
 │
 ├─ Afficher score
 ├─ delete game
 │
 ▼
Retour au Menu
```

---

## ÉTAPE 5 : Personnalisation et Modifications

### 5.1 Modifier un Jeu Existant

#### Exemple : Rendre Snake Plus Rapide

**Fichier** : `SnakeGame.h`

**Ligne à modifier** :
```cpp
// AVANT (ligne ~29)
int moveDelay;  // Vitesse initiale

void init() override {
    // ...
    moveDelay = 150;  // ← Délai en millisecondes
    // ...
}

// APRÈS (plus rapide)
void init() override {
    // ...
    moveDelay = 100;  // ← Valeur plus petite = plus rapide
    // ...
}
```

#### Exemple : Changer la Couleur du Serpent

```cpp
// AVANT (ligne ~89)
uint16_t color = (i == 0) ? TFT_YELLOW : TFT_GREEN;

// APRÈS (serpent rouge)
uint16_t color = (i == 0) ? TFT_YELLOW : TFT_RED;
```

### 5.2 Ajouter Votre Propre Jeu

**Template de base** :

```cpp
/*
 * MonNouveauJeu.h
 */

#ifndef MON_NOUVEAU_JEU_H
#define MON_NOUVEAU_JEU_H

#include "Game.h"

class MonNouveauJeu : public Game {
private:
    // VOS VARIABLES
    int playerX, playerY;
    int speed;
    
public:
    MonNouveauJeu(TFT_eSPI* display) : Game(display) {}
    
    void init() override {
        tft->fillScreen(TFT_BLACK);
        
        // INITIALISATION
        playerX = 120;
        playerY = 67;
        speed = 3;
        score = 0;
        gameOver = false;
    }
    
    void update(bool up, bool down, bool left, bool right, 
                bool a, bool b) override {
        if (gameOver) return;
        
        // LOGIQUE DU JEU
        if (left && playerX > 0) playerX -= speed;
        if (right && playerX < 240) playerX += speed;
        if (up && playerY > 0) playerY -= speed;
        if (down && playerY < 135) playerY += speed;
        
        // EXEMPLE : Incrémenter le score avec A
        if (a) {
            score += 10;
        }
        
        render();
    }
    
    void render() override {
        // AFFICHAGE
        tft->fillScreen(TFT_BLACK);
        
        // Dessiner le joueur
        tft->fillCircle(playerX, playerY, 8, TFT_CYAN);
        
        // Afficher le score
        displayScore();
    }
};

#endif
```

**Intégration** :

1. **Ajouter le #include** dans `TTGO_Arcade.ino` :
   ```cpp
   #include "MonNouveauJeu.h"  // ← Ajouter cette ligne
   ```

2. **Ajouter dans gameList** (ligne ~31) :
   ```cpp
   GameInfo gameList[NUM_GAMES] = {
     {"SNAKE", "Mange les pommes!", TFT_GREEN},
     // ... autres jeux
     {"MON JEU", "Description!", TFT_PURPLE},  // ← Nouveau
   };
   ```

3. **Augmenter NUM_GAMES** (ligne ~27) :
   ```cpp
   #define NUM_GAMES 11  // ← Était 10, maintenant 11
   ```

4. **Ajouter le case** dans launchGame() (ligne ~193) :
   ```cpp
   switch (gameIndex) {
     case 0: currentGame = new SnakeGame(&tft); break;
     // ... autres cases
     case 10: currentGame = new MonNouveauJeu(&tft); break;  // ← Nouveau
   }
   ```

5. **Compiler et uploader**

---

# 6. Théorie des Périphériques

## 6.1 Boutons et Debouncing

### Qu'est-ce que le Rebond (Bounce) ?

Quand vous appuyez sur un bouton mécanique, les contacts métalliques **ne se touchent pas instantanément**. Ils "rebondissent" plusieurs fois.

```
Signal réel d'un bouton (sans debouncing) :

Temps ──────────────────────────────────────→

Niveau
HIGH  ────┐     ┌┐  ┌┐ ┌──────────
          │     ││  ││ │
          │     ││  ││ │
LOW       └─────┘└──┘└─┘
          
          │←─────────────────→│
          Appui physique      │
          │                   │
          └─ Rebonds (1-10 ms)

Résultat : Le programme détecte 4 appuis au lieu d'1 !
```

### Solutions de Debouncing

#### Solution 1 : Hardware (Condensateur)

```
┌──────────────────────────────────────┐
│                                      │
│  3.3V ──[10kΩ]───┬─── GPIO          │
│                  │                   │
│           [Bouton] ─┬─ GND           │
│                     │                │
│                  [100nF]             │
│                     │                │
│                    GND               │
│                                      │
└──────────────────────────────────────┘

Le condensateur filtre les rebonds
```

#### Solution 2 : Software (Timer)

```cpp
// Variables pour debouncing
unsigned long lastDebounceTime = 0;
unsigned long debounceDelay = 50;  // 50 ms
bool lastButtonState = HIGH;
bool buttonState = HIGH;

void loop() {
    bool reading = digitalRead(BTN_PIN);
    
    // Si l'état a changé
    if (reading != lastButtonState) {
        lastDebounceTime = millis();
    }
    
    // Si stable pendant debounceDelay
    if ((millis() - lastDebounceTime) > debounceDelay) {
        if (reading != buttonState) {
            buttonState = reading;
            
            if (buttonState == LOW) {
                // Bouton appuyé de manière stable
                Serial.println("Button pressed!");
            }
        }
    }
    
    lastButtonState = reading;
}
```

**Notre implémentation** (dans TTGO_Arcade.ino) :

```cpp
struct ButtonState {
    bool up, down, left, right, a, b;
    unsigned long lastDebounce[6];
} buttons;

#define DEBOUNCE_DELAY 50

void readButtons() {
    unsigned long now = millis();
    
    if (now - buttons.lastDebounce[0] > DEBOUNCE_DELAY) {
        bool newState = !digitalRead(BTN_UP);
        if (newState != buttons.up) {
            buttons.up = newState;
            buttons.lastDebounce[0] = now;
        }
    }
    // ... répéter pour les autres boutons
}
```

## 6.2 Affichage TFT et Optimisations

### Hiérarchie de Vitesse

```
Opérations du plus rapide au plus lent :

1. fillRect() (couleur unie)
   └─ ~0.1 ms pour 100x100 pixels

2. drawPixel() (pixels individuels)
   └─ ~0.001 ms par pixel
   └─ 32,400 pixels = ~32 ms

3. drawLine(), drawCircle()
   └─ Appels multiples à drawPixel()

4. print() (texte)
   └─ Dessine des rectangles par caractère
   └─ ~0.5 ms par caractère

5. pushImage() (image bitmap)
   └─ Dépend de la taille
   └─ 50x50 RGB565 = ~5 ms
```

### Optimisation 1 : Dirty Rectangles

**Problème** : Redessiner tout l'écran = lent

**Solution** : Ne redessiner que ce qui a changé

```cpp
// ❌ LENT
void render() {
    tft->fillScreen(TFT_BLACK);  // Efface TOUT
    // Redessine tout...
}

// ✅ RAPIDE
void render() {
    // Effacer seulement l'ancienne position
    tft->fillRect(oldX, oldY, width, height, TFT_BLACK);
    
    // Dessiner à la nouvelle position
    tft->fillRect(newX, newY, width, height, TFT_COLOR);
    
    // Mettre à jour old
    oldX = newX;
    oldY = newY;
}
```

### Optimisation 2 : Buffers Hors-Écran

**Pour des animations complexes** :

```cpp
// Buffer en mémoire (SRAM)
uint16_t frameBuffer[240 * 135];  // ~64 KB

void render() {
    // 1. Dessiner dans le buffer (rapide, pas d'envoi SPI)
    for (int y = 0; y < 135; y++) {
        for (int x = 0; x < 240; x++) {
            frameBuffer[y * 240 + x] = calculateColor(x, y);
        }
    }
    
    // 2. Envoyer tout le buffer d'un coup (1 seul transfert SPI)
    tft->pushImage(0, 0, 240, 135, frameBuffer);
}
```

**Compromis** :
- ✅ Plus fluide
- ❌ Consomme 64 KB de RAM (sur 320 KB disponibles)

### Optimisation 3 : Sprites Pré-Rendus

```cpp
// Définir un sprite en Flash
const uint16_t playerSprite[16*16] PROGMEM = {
    TFT_CYAN, TFT_CYAN, TFT_BLACK, TFT_BLACK, /* ... */
};

void drawPlayer(int x, int y) {
    // Lire depuis Flash et afficher
    tft->pushImage(x, y, 16, 16, playerSprite);
}
```

## 6.3 Gestion de l'Alimentation

### Modes de Consommation ESP32

```
┌────────────────────────────────────────────────┐
│         Modes de Consommation                  │
├────────────────────────────────────────────────┤
│                                                │
│  Active (240 MHz, WiFi ON)                    │
│  └─ ~160-260 mA                               │
│                                                │
│  Active (240 MHz, WiFi OFF)                   │
│  └─ ~80-120 mA                                │
│                                                │
│  Modem Sleep (CPU ON, WiFi OFF)               │
│  └─ ~30-40 mA                                 │
│                                                │
│  Light Sleep (CPU pause, RAM OK)              │
│  └─ ~0.8 mA                                   │
│                                                │
│  Deep Sleep (CPU OFF, RTC ON)                 │
│  └─ ~10 µA (0.01 mA)                          │
│                                                │
│  Hibernation (tout OFF)                       │
│  └─ ~5 µA (0.005 mA)                          │
│                                                │
└────────────────────────────────────────────────┘
```

### Autonomie sur Batterie

**Calcul théorique** :

```
Batterie LiPo 500 mAh @ 3.7V

Consommation moyenne en jeu : ~100 mA

Autonomie = Capacité / Consommation
          = 500 mAh / 100 mA
          = 5 heures théoriques
          
En pratique : ~4 heures (pertes, efficacité régulateur)
```

### Économie d'Énergie

```cpp
// Réduire la luminosité du backlight
analogWrite(TFT_BL, 128);  // 50% luminosité (au lieu de 255)
// Économie : ~20 mA

// Réduire la fréquence CPU (si FPS OK)
setCpuFrequencyMhz(160);  // Au lieu de 240 MHz
// Économie : ~30 mA

// Désactiver WiFi/BT (si non utilisé)
WiFi.mode(WIFI_OFF);
btStop();
// Économie : ~40 mA
```

---

# 7. Debugging et Troubleshooting

## 7.1 Outils de Diagnostic

### Serial Monitor

**Configuration** :
```cpp
void setup() {
    Serial.begin(115200);  // Vitesse : 115200 baud
    Serial.println("=== Debug Start ===");
}

void loop() {
    Serial.print("Variable X = ");
    Serial.println(x);
    delay(1000);
}
```

**Ouvrir le Serial Monitor** :
- Arduino IDE : `Outils` → `Moniteur série`
- Ou raccourci : `Ctrl+Shift+M` (Windows/Linux), `Cmd+Shift+M` (Mac)
- **Régler la vitesse** en bas à droite : 115200 baud

### Debug Prints Efficaces

```cpp
// ❌ MAUVAIS (pas assez d'info)
Serial.println("Error");

// ✅ BON (contexte complet)
Serial.print("[ERROR] Failed to initialize screen. Code: ");
Serial.println(errorCode);

// ✅ EXCELLENT (timestamp + contexte)
Serial.print("[");
Serial.print(millis());
Serial.print(" ms] Player position: (");
Serial.print(playerX);
Serial.print(", ");
Serial.print(playerY);
Serial.println(")");
```

### Macros de Debug

```cpp
// En haut du fichier
#define DEBUG 1

#if DEBUG
  #define DEBUG_PRINT(x) Serial.print(x)
  #define DEBUG_PRINTLN(x) Serial.println(x)
#else
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINTLN(x)
#endif

// Utilisation
void loop() {
    DEBUG_PRINTLN("Loop start");
    // ...
}

// Pour désactiver les prints : #define DEBUG 0
```

### Multimètre - Mesures Électriques

**Mesure de tension** :
```
Multimètre en mode VDC (Voltage DC)

Sonde rouge (+) → GPIO à mesurer
Sonde noire (-) → GND

Valeurs attendues :
• Bouton non appuyé : ~3.3V (pull-up)
• Bouton appuyé : ~0V (connecté à GND)
• Alimentation 3.3V : 3.2-3.4V
• Alimentation USB : 4.8-5.2V
```

**Mesure de continuité** :
```
Multimètre en mode continuité (🔊)

Test 1 : Vérifier qu'un câble conduit
• Sonde rouge → Extrémité 1
• Sonde noire → Extrémité 2
• Bip = continuité OK

Test 2 : Vérifier un bouton
• Sondes sur les 2 pattes du bouton
• Non appuyé : pas de bip
• Appuyé : bip
```

## 7.2 Problèmes Fréquents et Solutions

### Problème : Écran Blanc/Noir

**Diagnostic** :
```cpp
void setup() {
    Serial.begin(115200);
    
    Serial.println("Initializing TFT...");
    tft.init();
    Serial.println("TFT initialized");
    
    Serial.print("Width: ");
    Serial.println(tft.width());
    Serial.print("Height: ");
    Serial.println(tft.height());
    
    tft.fillScreen(TFT_RED);
    Serial.println("Screen should be RED");
    delay(2000);
}
```

**Solutions par cause** :

| Symptôme | Cause Probable | Solution |
|----------|----------------|----------|
| Écran noir total | Backlight OFF | Vérifier GPIO 4 (TFT_BL) |
| Écran blanc | Mauvais Setup | Vérifier Setup25_TTGO |
| Pixels aléatoires | Mauvaise init | Ajouter tft.init(); delay(100); |
| Écran à l'envers | Rotation | tft.setRotation(1); |

### Problème : Boutons Ne Répondent Pas

**Diagnostic méthodique** :

1. **Test logiciel** :
```cpp
void loop() {
    int btnValue = digitalRead(BTN_PIN);
    Serial.print("Button value: ");
    Serial.println(btnValue);
    delay(100);
}
```

   **Résultats** :
   - Toujours 1 → Pas connecté ou pull-up manquant
   - Toujours 0 → Court-circuit à GND
   - Change avec appui → OK

2. **Test hardware** :
   - Multimètre en continuité
   - Tester le bouton seul
   - Vérifier les connexions

3. **Vérifier INPUT_PULLUP** :
```cpp
// ❌ OUBLIÉ
pinMode(BTN_PIN, INPUT);

// ✅ CORRECT
pinMode(BTN_PIN, INPUT_PULLUP);
```

### Problème : Crash / Reset Aléatoire

**Causes possibles** :

1. **Stack Overflow** :
```cpp
// ❌ MAUVAIS (trop de variables locales)
void bigFunction() {
    uint8_t hugeArray[10000];  // 10 KB sur le stack !
    // ...
}

// ✅ BON (utiliser heap ou global)
uint8_t* hugeArray;

void setup() {
    hugeArray = (uint8_t*)malloc(10000);
}
```

2. **Watchdog Timer** :
```cpp
// Si une fonction prend trop de temps
void longCalculation() {
    for (int i = 0; i < 1000000; i++) {
        // Calcul long...
        
        // Réinitialiser le watchdog tous les 100ms
        if (i % 10000 == 0) {
            yield();  // ou delay(1);
        }
    }
}
```

3. **Déréférencement de pointeur NULL** :
```cpp
// ❌ DANGEREUX
Game* game = nullptr;
game->update();  // CRASH !

// ✅ SÉCURISÉ
if (game != nullptr) {
    game->update();
}
```

### Problème : Upload Échoue

**Messages d'erreur courants** :

```
"Failed to connect to ESP32: Timed out waiting for packet header"
→ Solution : Mode BOOT manuel (voir Étape 3.3)

"A fatal error occurred: MD5 of file does not match data in flash!"
→ Solution : 
  1. Effacer la flash : Outils → Erase Flash → All Flash Contents
  2. Re-uploader

"error: cannot access /dev/ttyUSB0"
→ Solution (Linux) :
  sudo usermod -a -G dialout $USER
  (puis redémarrer)

"pyserial or esptool not installed"
→ Solution : Réinstaller le package ESP32
```

## 7.3 Analyse de Performance

### Mesure du Framerate

```cpp
void loop() {
    static unsigned long lastFrame = 0;
    static int frameCount = 0;
    
    // Votre code de rendu...
    render();
    
    // Calcul FPS
    frameCount++;
    if (millis() - lastFrame >= 1000) {
        float fps = frameCount / ((millis() - lastFrame) / 1000.0);
        
        Serial.print("FPS: ");
        Serial.println(fps);
        
        frameCount = 0;
        lastFrame = millis();
    }
}
```

### Profilage de Code

```cpp
void complexFunction() {
    unsigned long start = micros();
    
    // Code à mesurer
    for (int i = 0; i < 1000; i++) {
        doSomething();
    }
    
    unsigned long elapsed = micros() - start;
    Serial.print("Execution time: ");
    Serial.print(elapsed);
    Serial.println(" µs");
}
```

### Surveillance de la Mémoire

```cpp
void printMemoryInfo() {
    Serial.print("Free heap: ");
    Serial.print(ESP.getFreeHeap());
    Serial.println(" bytes");
    
    Serial.print("Largest free block: ");
    Serial.print(ESP.getMaxAllocHeap());
    Serial.println(" bytes");
    
    Serial.print("Heap fragmentation: ");
    Serial.print(100 - (ESP.getMaxAllocHeap() * 100) / ESP.getFreeHeap());
    Serial.println("%");
}
```

---

# 8. Optimisations Avancées

## 8.1 Utilisation du Dual-Core

L'ESP32 a **2 cœurs indépendants**. On peut les utiliser pour paralléliser :

```cpp
// Core 0 : Logique du jeu
void gameTask(void* parameter) {
    while (true) {
        updateGameLogic();
        vTaskDelay(1);  // 1 ms
    }
}

// Core 1 : Affichage
void renderTask(void* parameter) {
    while (true) {
        renderGraphics();
        vTaskDelay(16);  // ~60 FPS
    }
}

void setup() {
    // Créer les tâches
    xTaskCreatePinnedToCore(
        gameTask,      // Fonction
        "GameLogic",   // Nom
        10000,         // Stack size
        NULL,          // Paramètres
        1,             // Priorité
        NULL,          // Handle
        0              // Core 0
    );
    
    xTaskCreatePinnedToCore(
        renderTask,
        "Render",
        10000,
        NULL,
        1,
        NULL,
        1              // Core 1
    );
}

void loop() {
    // Vide (tout géré par les tâches)
}
```

## 8.2 DMA (Direct Memory Access)

Le DMA permet de transférer des données **sans intervention du CPU** :

```cpp
// Configuration DMA pour SPI
void setupDMA() {
    // Configuration avancée du SPI avec DMA
    // Permet d'envoyer de gros buffers à l'écran
    // pendant que le CPU fait autre chose
}

// Exemple conceptuel
void renderWithDMA() {
    // Préparer le buffer
    prepareFrameBuffer();
    
    // Lancer le transfert DMA (non-bloquant)
    spi_dma_transfer(frameBuffer, bufferSize);
    
    // Pendant ce temps, calculer la frame suivante
    calculateNextFrame();
    
    // Attendre que le DMA soit fini
    spi_dma_wait();
}
```

## 8.3 Optimisations du Compilateur

```cpp
// Forcer l'inlining pour les fonctions critiques
inline __attribute__((always_inline)) 
int fastFunction(int x) {
    return x * 2 + 1;
}

// Placer du code en IRAM (RAM rapide)
void IRAM_ATTR criticalCode() {
    // Code qui s'exécute souvent
}

// Attributs de compilation utiles
#pragma GCC optimize("O3")              // Optimisation maximale
#pragma GCC optimize("unroll-loops")    // Dérouler les boucles
```

---

# 9. Ressources et Références

## 9.1 Documentation Officielle

### ESP32
```
• Espressif Documentation
  https://docs.espressif.com/projects/esp-idf/

• ESP32 Technical Reference
  https://www.espressif.com/sites/default/files/documentation/esp32_technical_reference_manual_en.pdf

• ESP32 Datasheet
  https://www.espressif.com/sites/default/files/documentation/esp32_datasheet_en.pdf
```

### Arduino ESP32
```
• Arduino-ESP32 GitHub
  https://github.com/espressif/arduino-esp32

• API Reference
  https://docs.espressif.com/projects/arduino-esp32/
```

### TFT_eSPI
```
• TFT_eSPI GitHub
  https://github.com/Bodmer/TFT_eSPI

• Setup Files
  https://github.com/Bodmer/TFT_eSPI/tree/master/User_Setups
```

## 9.2 Communautés et Forums

```
• ESP32 Forum (officiel)
  https://www.esp32.com/

• Arduino Forum - ESP32 Section
  https://forum.arduino.cc/c/hardware/esp32/

• Reddit r/esp32
  https://www.reddit.com/r/esp32/

• Discord ESP32
  https://discord.gg/esp32
```

## 9.3 Livres et Tutoriels

```
• "Getting Started with ESP32" (Kolban)
  eBook gratuit sur ESP32

• Random Nerd Tutorials
  https://randomnerdtutorials.com/projects-esp32/
  Tutoriels pratiques ESP32

• DroneBot Workshop
  https://dronebotworkshop.com/
  Vidéos éducatives électronique
```

## 9.4 Outils Utiles

### Logiciels
```
• PlatformIO (alternative à Arduino IDE)
  https://platformio.org/

• ESP32 Flash Download Tool
  https://www.espressif.com/en/support/download/other-tools

• Fritzing (schémas électroniques)
  https://fritzing.org/
```

### Simulateurs
```
• Wokwi (simulateur ESP32 en ligne)
  https://wokwi.com/
  Peut tester du code sans hardware !

• Tinkercad Circuits
  https://www.tinkercad.com/circuits
```

## 9.5 Composants et Fournisseurs

### Sites Recommandés
```
• AliExpress : Pas cher, long délai (Chine)
• Amazon : Plus cher, rapide
• Mouser / DigiKey : Professionnel, fiable
• Adafruit / SparkFun : Qualité, tutoriels
```

### Kits Recommandés
```
• Kit ESP32 Starter
  ├─ TTGO T-Display
  ├─ Breadboard
  ├─ Câbles jumper
  ├─ Boutons
  ├─ LEDs
  └─ Résistances

Prix : ~25-35€
```

---

# 10. Conclusion et Projet Final

## 10.1 Récapitulatif du Projet

Vous avez maintenant :

✅ **Compris** l'architecture ESP32
✅ **Maîtrisé** le câblage sécurisé
✅ **Configuré** l'environnement de développement
✅ **Créé** une console de jeux fonctionnelle
✅ **Appris** à déboguer et optimiser

## 10.2 Améliorations Possibles

### Court Terme (1-2 semaines)
```
□ Ajouter du son avec un buzzer
□ Créer un boîtier imprimé 3D
□ Ajouter un système de high scores
□ Créer 2-3 jeux supplémentaires
```

### Moyen Terme (1-2 mois)
```
□ Implémenter un mode 2 joueurs
□ Ajouter WiFi pour multijoueur en ligne
□ Créer un éditeur de niveaux
□ Porter des jeux Arduboy (si code source)
```

### Long Terme (3+ mois)
```
□ Développer un émulateur AVR complet
□ Créer une marketplace de jeux
□ Système d'exploitation complet
□ Version commercialisable
```

## 10.3 Checklist Finale

```
Avant de considérer le projet "terminé" :

Hardware :
□ Tous les boutons fonctionnent parfaitement
□ Écran affiche correctement
□ Alimentation stable
□ Pas de faux contacts
□ Câblage propre et organisé

Software :
□ Tous les jeux sont jouables
□ Pas de bugs critiques
□ FPS stable (>30 FPS minimum)
□ Mémoire bien gérée (pas de leaks)
□ Code commenté et organisé

Documentation :
□ Schéma électrique dessiné
□ Photos du montage
□ README avec instructions
□ Vidéo de démonstration

Bonus :
□ Boîtier / Protection
□ Batterie pour portabilité
□ Nom/Logo personnalisé
□ Partagé avec la communauté
```

## 10.4 Message Final

Félicitations ! Vous venez de réaliser un projet complet de système embarqué, de la compréhension du matériel au développement logiciel.

**Compétences acquises** :
- 🔌 Électronique digitale
- 💻 Programmation embarquée
- 🎮 Développement de jeux
- 🐛 Debugging méthodique
- 📐 Gestion de projet

**Certificat de compétences** :
```
┌────────────────────────────────────────────┐
│                                            │
│         🎓 INGÉNIEUR EMBARQUÉ 🎓          │
│                                            │
│   Vous maîtrisez maintenant :             │
│                                            │
│   ✓ Architecture ESP32                    │
│   ✓ Protocoles SPI                        │
│   ✓ Gestion de mémoire                    │
│   ✓ Optimisation temps réel               │
│   ✓ Développement de jeux                 │
│                                            │
│   Prochaine étape : Créez l'impossible !  │
│                                            │
└────────────────────────────────────────────┘
```

**N'oubliez pas** :
- 🚀 Commencez simple, itérez
- 📖 La documentation est votre amie
- 🤝 La communauté est là pour aider
- 💡 Chaque bug est une opportunité d'apprendre
- 🎉 Célébrez chaque petite victoire

**Bon courage et amusez-vous ! 🎮**

---

*Document créé avec ❤️ par un ingénieur passionné*
*Version 1.0 - Mars 2026*
