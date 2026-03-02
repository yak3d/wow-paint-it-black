# Paint It Black

A World of Warcraft addon that reminds you to drink your Inky Black Potion when night falls and to remove the buff when day breaks.

## Features

- Configurable night and day boundaries (defaults: 19:00 and 06:00)
- Adjustable reminder interval (1 to 30 minutes, default 5)
- Alerts via on-screen popup, chat message, and sound
- Defers reminders while in combat
- Tracks whether you've already acted so it won't spam you

## Configuration

All settings are found in the WoW Settings panel under Addons, or by typing `/pib` in chat.

| Option                       | Type     | Format   | Default | Description                                         |
|------------------------------|----------|----------|---------|-----------------------------------------------------|
| Enable Reminders             | Checkbox | on/off   | on      | Toggle all Inky Black Potion reminders               |
| Debug Mode                   | Checkbox | on/off   | off     | Print debug messages to chat                         |
| Night Starts                 | Text     | HH:MM    | 19:00   | When "use potion" reminders begin                    |
| Day Starts                   | Text     | HH:MM    | 06:00   | When "remove buff" reminders begin                   |
| Reminder Interval (minutes)  | Slider   | 1--30    | 5       | Minutes between repeated reminders                   |
| Alert Duration (seconds)     | Slider   | 1--60    | 5       | How long the on-screen alert stays visible           |
| Alert Sound                  | Dropdown | —        | Whisper | Sound played with reminders (select to preview)      |

Settings are saved per-character in `PaintItBlackDB` and persist across sessions.

## Commands

| Command      | Description                          |
|--------------|--------------------------------------|
| `/pib`       | Open the settings panel              |
| `/pibdebug`  | Dump internal state to chat (requires Debug Mode) |

## Installation

### Using the Makefile

```sh
make install WOW_DIR='/path/to/World of Warcraft'
```

This creates a symlink from the addon source directory into your WoW AddOns folder at `_retail_/Interface/AddOns/PaintItBlack`.

To remove the symlink:

```sh
make uninstall WOW_DIR='/path/to/World of Warcraft'
```

Run `make help` to see available targets.

### Manual

Copy or symlink the `PaintItBlack/` directory into your WoW `_retail_/Interface/AddOns/` folder.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, issue reporting, and PR guidelines.
