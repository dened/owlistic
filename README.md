# Owlistic

[![Checkout](https://github.com/dened/owlistic/actions/workflows/checkout.yml/badge.svg)](https://github.com/dened/owlistic/actions) 
[![Build](https://github.com/dened/owlistic/actions/workflows/build.yml/badge.svg)](https://github.com/dened/owlistic/actions)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT) 

**Owlistic** is a Telegram bot written in Dart. It helps users automatically track their Telc exam results by allowing them to register their exam details and receive notifications when their certificates become available.

## ✨ Features

-   **Automatic Certificate Checking**: Periodically queries the Telc portal for certificate availability for registered users.
-   **Telegram Notifications**: Notifies users via Telegram when their certificate is found or if there's an update on the search status.
-   **User Data Registration**: Allows users to securely save their Telc participant number, birth date, and exam date.
-   **Data Management**: Users can view their registered information and delete specific entries or all their data.
-   **On-Demand Checking**: Provides a `/check_now` command for users to trigger an immediate search for their results.
-   **Separate Lookup Service**: Includes `bin/lookup_service.dart`, a command-line utility for performing certificate lookups. This can be run manually or scheduled (e.g., via cron) for batch processing.
-   **Data Processing Consent**: Implements a consent flow during the `/start` command, requiring users to agree to a privacy policy before their data is stored.
-   **Localization**: Supports multiple interface languages (e.g., English, German, Russian - configurable via `*.arb` files).
-   **SQLite Storage**: Uses an SQLite database for persistent storage of user information, search criteria, and consent status.
-   **Flexible Configuration**: Configurable via command-line arguments or a `.env` file for both the bot and the lookup service.
-   **Cross-Platform**: Runs on Windows, macOS, and Linux. Docker support can be easily implemented.
-   **Open-Source**: Available under the MIT License (or your chosen license).

<!-- Add screenshots of the bot in action here -->

## 🚀 Getting Started

The application consists of two main executable components: the Telegram Bot and the Lookup Service.

### 💻 Minimum System Requirements

-   **Operating System**: Windows, macOS, or a recent Linux distribution.
-   **Processor**: x86_64 or ARM64.
-   **Memory**: 64 MB RAM (128 MB recommended for smoother operation, especially with many users).
-   **Storage**: 50 MB available space (plus space for the SQLite database, which will grow with user data).
-   **Dart SDK**: Version `^3.5.4` or compatible (see `pubspec.yaml` for specific constraints).
-   **Docker**: (Optional) For running the application in a containerized environment.

### 🔧 Install Dependencies

1.  Ensure you have the Dart SDK installed.
2.  Clone this repository:
    ```sh
    git clone https://github.com/dened/owlistic.git
    cd owlistic
    ```
3.  Install dependencies and generate necessary files:
    ```sh
    dart pub get
    dart run build_runner build --delete-conflicting-outputs
    ```

### ▶️ Run the Application

**1. Telegram Bot (`bin/owlistic.dart`)**

This script runs the main Telegram bot that users interact with.

*   **Using command-line arguments:**
    ```sh
    dart run bin/owlistic.dart --token="YOUR_TELEGRAM_TOKEN" --privacy-policy-url="https://yourdomain.com/privacy" 
    ```

*   **Using a `.env` file:**
    Create a `.env` file in the project root (e.g., `owlistic/.env`):
    ```env
    token="YOUR_TELEGRAM_TOKEN"
    privacy-policy-url="https://yourdomain.com/privacy"
    ```
    Then, run the bot:
    ```sh
    dart run bin/owlistic.dart
    ```

**2. Certificate Lookup Service (`bin/lookup_service.dart`)**

This script is designed for periodic execution (e.g., by a cron job) to check for certificates for all registered users or for a specific user. It uses the same configuration mechanisms.

*   **To check for all users:**
    ```sh
    dart run bin/lookup_service.dart --token="YOUR_TELEGRAM_TOKEN" 
    ```
    (Ensure `TOKEN` is provided if notifications are sent directly by this service, or if it needs to interact with bot functionalities that require the token).

*   **To check for a specific user (replace `USER_CHAT_ID`):**
    ```sh
    dart run bin/lookup_service.dart --token="YOUR_TELEGRAM_TOKEN" --chat-id=USER_CHAT_ID --check-days=15
    ```
    The `.env` file will also be read by this script if present.

## ⚙️ Configuration

Configuration can be provided via command-line arguments or a `.env` file located in the project root. Command-line arguments take precedence over `.env` variables.
The application's `Arguments` class determines how environment variables are loaded. Typically, for an option like `--token`, the corresponding environment variable would be `TOKEN`. Please verify with the `Arguments` class implementation if a prefix (e.g., `CONFIG_`) is used.

| Argument                 | Environment Variable (`.env`) Example | Description                                                                                                | Default Value          | Used By         |
| :----------------------- | :------------------------------------ | :--------------------------------------------------------------------------------------------------------- | :--------------------- | :-------------- |
| `-t`, `--token`          | `TOKEN`                               | **(Required)** Your Telegram bot API token.                                                                | —                      | Both            |
| `--privacy-policy-url`   | `PRIVACY_POLICY_URL`                  | **(Required)** URL to your privacy policy document. This is shown to users during the `/start` consent flow. | —                      | Both            |
| `-d`, `--db`             | `DB_PATH`                             | Path to the SQLite database file.                                                                          | `data/owlistic.db`     | Both            |
| `-v`, `--verbose`        | `VERBOSE_LEVEL`                       | Logging verbosity. Options: `all`, `debug`, `info`, `warn`, `error`.                                       | `info`                 | Both            |
| `-c`, `--chat-id`        | `CHAT_ID`                             | (Integer) Specific chat ID to check. If not provided, `lookup_service` checks all eligible users.          | —                      | `lookup_service`|
| `--check-days`           | `CHECK_DAYS`                          | (Integer) How many days to check from today and back.                                                      | `10`                   | `lookup_service`|
| `--help`                 |                                       | Show help message detailing all options and exit.                                                          |                        | Both            |

To see all available command-line options for each script, run:
```sh
dart run bin/owlistic.dart --help
dart run bin/lookup_service.dart --help
```

## 🤖 Bot Commands

The bot supports the following commands:

-   `/start` - Initiates interaction, displays the privacy policy, and asks for user consent to process data.
-   `/help` - Shows a list of available commands and their descriptions.
-   `/add` - Starts a guided conversation to add Telc exam details (attendee number, birth date, exam date) for result tracking.
-   `/show` - Displays the exam information currently registered by the user with the bot.
-   `/delete` - Allows the user to delete one or all of their registered exam entries via an inline keyboard.
-   `/check_now` - Triggers an immediate check for the user's registered exam results.
-   `/language` - Allows the user to change the bot's interface language using an inline keyboard.
-   `/delete_me` - Prompts the user for confirmation to delete all their data from the bot, including consent records and registered exam information.

## 🏗️ Building

### 🛠️ How to Compile
```sh
dart pub get
dart run build_runner build --delete-conflicting-outputs
dart compile exe bin/owlistic.dart -o owlistic.run
dart compile exe bin/lookup_service.dart -o lookup_service.run
```

