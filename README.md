# coinbar

Track cryptocurrency prices from the macOS menu bar without browser tabs or bloated apps

[![CI](https://github.com/ivoronin/CoinBar/actions/workflows/test.yml/badge.svg)](https://github.com/ivoronin/CoinBar/actions/workflows/test.yml)
[![Release](https://img.shields.io/github/v/release/ivoronin/CoinBar)](https://github.com/ivoronin/CoinBar/releases)

[Overview](#overview) · [Features](#features) · [Installation](#installation) · [Usage](#usage) · [Requirements](#requirements) · [License](#license)

Install with Homebrew and a live price ticker appears in your menu bar within seconds:

```bash
brew install ivoronin/ivoronin/coinbar
open /opt/homebrew/Cellar/coinbar/*/CoinBar.app
```

The menu bar shows `BTC/USD 104,230` (or whichever coin/currency pair you configure). Click it to change coins, currencies, or toggle display options.

## Overview

CoinBar is a native macOS menu bar app built with SwiftUI. It polls the CoinGecko API every 60 seconds to fetch the current price of a selected cryptocurrency in a chosen fiat currency. All preferences (coin, currency, display format) are persisted in UserDefaults and take effect immediately.

## Features

- Live price display in the menu bar, updated every 60 seconds
- 14,000+ coins via the CoinGecko API (no API key required)
- Searchable coin and currency pickers
- Optional trading pair label (e.g. `BTC/USD` prefix)
- Launch at login via LaunchAgent
- Native SwiftUI, no Electron or web views
- Runs as a menu bar accessory (no Dock icon)

## Installation

### Homebrew

```bash
brew install ivoronin/ivoronin/coinbar
```

### Build from Source

```bash
git clone https://github.com/ivoronin/CoinBar.git
cd CoinBar
make app
open CoinBar.app
```

## Usage

CoinBar lives in the macOS menu bar. Click the price ticker to open the settings popover:

- **Coin** - search and select from 14,000+ cryptocurrencies
- **Currency** - search and select a fiat currency (USD, EUR, GBP, etc.)
- **Show Pair** - toggle the `BTC/USD` prefix on or off
- **Launch at Login** - start CoinBar automatically when you log in
- **Refresh** - manually refresh the price (also shows errors in red if the API is unreachable)
- **Quit** - exit the app

Keyboard shortcuts: `Cmd+R` to refresh, `Cmd+Q` to quit.

## Requirements

- macOS 14+
- Xcode 16+ (for building from source)

## License

[GPL-3.0](LICENSE)
