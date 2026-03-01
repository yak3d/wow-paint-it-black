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

| Option                       | Type     | Range    | Default | Description                                         |
|------------------------------|----------|----------|---------|-----------------------------------------------------|
| Enable Reminders             | Checkbox | on/off   | on      | Toggle all Inky Black Potion reminders               |
| Debug Mode                   | Checkbox | on/off   | off     | Print debug messages to chat                         |
| Night Starts (Hour)          | Slider   | 0--23    | 19      | Hour when "use potion" reminders begin (24h format)  |
| Night Starts (Minute)        | Slider   | 0--59    | 0       | Minute offset for night start                        |
| Day Starts (Hour)            | Slider   | 0--23    | 6       | Hour when "remove buff" reminders begin (24h format) |
| Day Starts (Minute)          | Slider   | 0--59    | 0       | Minute offset for day start                          |
| Reminder Interval (minutes)  | Slider   | 1--30    | 5       | Minutes between repeated reminders                   |
| Alert Duration (seconds)     | Slider   | 1--30    | 5       | How long the on-screen alert stays visible           |

Settings are saved per-character in `PaintItBlackDB` and persist across sessions.

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

### Local Development

Use the Makefile to manage your local installation during development:

| Target      | Description                                      |
|-------------|--------------------------------------------------|
| `help`      | Print usage information                          |
| `install`   | Symlink the addon into your WoW AddOns directory |
| `uninstall` | Remove the addon symlink                         |
| `clean`     | Alias for `uninstall`                            |

All targets that interact with the WoW directory require the `WOW_DIR` variable:

```sh
make install WOW_DIR='/path/to/World of Warcraft'
```

### Reporting Issues

Please report bugs and feature requests through the GitLab Issues tracker. Pull requests are welcome, but an issue must exist before a PR is opened. Reference the relevant issue number in your PR description.

### Generated Code

Any pull request that contains generated code (from AI tools, code generators, scaffolding utilities, or similar) must have a human author who is responsible for reviewing, understanding, and managing the PR. The human author must be able to explain every change in the PR and respond to review feedback. PRs that consist solely of unreviewed generated output will be closed.
