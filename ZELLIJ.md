# My Zellij Setup

A walkthrough of how I've configured [Zellij](https://zellij.dev/) — a terminal multiplexer. This covers the keybinding remaps, theme, plugins, layouts, and shell aliases I use day-to-day.

## Why remap the defaults?

Zellij ships with mode switches on `Ctrl g/p/n/s/o/h/b` etc., which conflict with common shell and editor bindings I already rely on (`Ctrl r`, `Ctrl p` in fuzzy finders, `Ctrl s` in editors, etc.). I kept Zellij's modal structure but moved every mode switch onto the **left-hand home row** under `Ctrl`, so switching modes is a one-handed motion.

The mapping is:

| Mode     | Default  | My binding |
| -------- | -------- | ---------- |
| Locked   | `Ctrl g` | `Ctrl l`   |
| Pane     | `Ctrl p` | `Ctrl k`   |
| Resize   | `Ctrl n` | `Ctrl h`   |
| Scroll   | `Ctrl s` | `Ctrl g`   |
| Session  | `Ctrl o` | `Ctrl s`   |
| Move     | `Ctrl h` | `Ctrl b`   |
| Tab      | `Ctrl t` | `Ctrl t`   |
| Tmux     | (off)    | (disabled) |

Once I'm in a mode, the exit key is whichever key got me in, so it's symmetrical. Within each mode, I keep vim-style `h/j/k/l` for movement/resize.

## Config

`~/.config/zellij/config.kdl`:

```kdl
// keybinds clear-defaults=true means: discard Zellij's defaults entirely
// and use only what's defined below. Safer than merging, since partial
// overrides leave the unwanted defaults in place.
keybinds clear-defaults=true {
    normal {
        // uncomment this and adjust key if using copy_on_select=false
        // bind "Alt c" { Copy; }
    }
    locked {
        bind "Ctrl l" { SwitchToMode "Normal"; }
    }
    resize {
        bind "Ctrl h" { SwitchToMode "Normal"; }
        bind "h" "Left"  { Resize "Left"; }
        bind "j" "Down"  { Resize "Down"; }
        bind "k" "Up"    { Resize "Up"; }
        bind "l" "Right" { Resize "Right"; }
        bind "=" "+"     { Resize "Increase"; }
        bind "-"         { Resize "Decrease"; }
    }
    pane {
        bind "Ctrl k" { SwitchToMode "Normal"; }
        bind "h" "Left"  { MoveFocus "Left"; }
        bind "l" "Right" { MoveFocus "Right"; }
        bind "j" "Down"  { MoveFocus "Down"; }
        bind "k" "Up"    { MoveFocus "Up"; }
        bind "p" { SwitchFocus; }
        bind "n" { NewPane; SwitchToMode "Normal"; }
        bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
        bind "r" { NewPane "Right"; SwitchToMode "Normal"; }
        bind "x" { CloseFocus; SwitchToMode "Normal"; }
        bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
        bind "z" { TogglePaneFrames; SwitchToMode "Normal"; }
        bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
        bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
        bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0; }
    }
    move {
        bind "Ctrl b" { SwitchToMode "Normal"; }
        bind "n" "Tab"   { MovePane; }
        bind "h" "Left"  { MovePane "Left"; }
        bind "j" "Down"  { MovePane "Down"; }
        bind "k" "Up"    { MovePane "Up"; }
        bind "l" "Right" { MovePane "Right"; }
    }
    tab {
        bind "Ctrl t" { SwitchToMode "Normal"; }
        bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
        bind "h" "Left"  "Up"   "k" { GoToPreviousTab; }
        bind "l" "Right" "Down" "j" { GoToNextTab; }
        bind "n" { NewTab; SwitchToMode "Normal"; }
        bind "x" { CloseTab; SwitchToMode "Normal"; }
        bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
        bind "b" { BreakPane; SwitchToMode "Normal"; }
        bind "]" { BreakPaneRight; SwitchToMode "Normal"; }
        bind "[" { BreakPaneLeft; SwitchToMode "Normal"; }
        bind "1" { GoToTab 1; SwitchToMode "Normal"; }
        bind "2" { GoToTab 2; SwitchToMode "Normal"; }
        bind "3" { GoToTab 3; SwitchToMode "Normal"; }
        bind "4" { GoToTab 4; SwitchToMode "Normal"; }
        bind "5" { GoToTab 5; SwitchToMode "Normal"; }
        bind "6" { GoToTab 6; SwitchToMode "Normal"; }
        bind "7" { GoToTab 7; SwitchToMode "Normal"; }
        bind "8" { GoToTab 8; SwitchToMode "Normal"; }
        bind "9" { GoToTab 9; SwitchToMode "Normal"; }
        bind "Tab" { ToggleTab; }
    }
    scroll {
        bind "Ctrl l" { SwitchToMode "Normal"; }
        bind "e" { EditScrollback; SwitchToMode "Normal"; }
        bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
        bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
        bind "j" "Down" { ScrollDown; }
        bind "k" "Up"   { ScrollUp; }
        bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
        bind "Ctrl b" "PageUp"   "Left"  "h" { PageScrollUp; }
        bind "d" { HalfPageScrollDown; }
        bind "u" { HalfPageScrollUp; }
    }
    search {
        bind "Ctrl s" { SwitchToMode "Normal"; }
        bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
        bind "j" "Down" { ScrollDown; }
        bind "k" "Up"   { ScrollUp; }
        bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
        bind "Ctrl b" "PageUp"   "Left"  "h" { PageScrollUp; }
        bind "d" { HalfPageScrollDown; }
        bind "u" { HalfPageScrollUp; }
        bind "n" { Search "down"; }
        bind "p" { Search "up"; }
        bind "c" { SearchToggleOption "CaseSensitivity"; }
        bind "w" { SearchToggleOption "Wrap"; }
        bind "o" { SearchToggleOption "WholeWord"; }
    }
    entersearch {
        bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
        bind "Enter" { SwitchToMode "Search"; }
    }
    renametab {
        bind "Ctrl c" { SwitchToMode "Normal"; }
        bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
    }
    renamepane {
        bind "Ctrl c" { SwitchToMode "Normal"; }
        bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
    }
    session {
        bind "Ctrl s" { SwitchToMode "Normal"; }
        bind "Ctrl g" { SwitchToMode "Scroll"; }
        bind "d" { Detach; }
        bind "m" {
            LaunchOrFocusPlugin "zellij:session-manager" {
                floating true
                move_to_focused_tab true
            };
            SwitchToMode "Normal"
        }
    }
    tmux {
        bind "[" { SwitchToMode "Scroll"; }
        bind "Ctrl b" { Write 2; SwitchToMode "Normal"; }
        bind "\"" { NewPane "Down"; SwitchToMode "Normal"; }
        bind "%" { NewPane "Right"; SwitchToMode "Normal"; }
        bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
        bind "c" { NewTab; SwitchToMode "Normal"; }
        bind "," { SwitchToMode "RenameTab"; }
        bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
        bind "n" { GoToNextTab; SwitchToMode "Normal"; }
        bind "Left"  { MoveFocus "Left";  SwitchToMode "Normal"; }
        bind "Right" { MoveFocus "Right"; SwitchToMode "Normal"; }
        bind "Down"  { MoveFocus "Down";  SwitchToMode "Normal"; }
        bind "Up"    { MoveFocus "Up";    SwitchToMode "Normal"; }
        bind "h" { MoveFocus "Left";  SwitchToMode "Normal"; }
        bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
        bind "j" { MoveFocus "Down";  SwitchToMode "Normal"; }
        bind "k" { MoveFocus "Up";    SwitchToMode "Normal"; }
        bind "o" { FocusNextPane; }
        bind "d" { Detach; }
    }
    shared_except "locked" {
        bind "Ctrl l" { SwitchToMode "Locked"; }
        bind "Ctrl q" { Quit; }
        bind "Alt n" { NewPane; }
        bind "Alt h" "Alt Left"  { MoveFocusOrTab "Left"; }
        bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
        bind "Alt j" "Alt Down"  { MoveFocus "Down"; }
        bind "Alt k" "Alt Up"    { MoveFocus "Up"; }
        bind "Alt =" "Alt +"     { Resize "Increase"; }
        bind "Alt -"             { Resize "Decrease"; }
    }
    shared_except "normal" "locked" {
        bind "Enter" "Esc" { SwitchToMode "Normal"; }
    }
    shared_except "pane"    "locked" { bind "Ctrl k" { SwitchToMode "Pane"; } }
    shared_except "resize"  "locked" { bind "Ctrl h" { SwitchToMode "Resize"; } }
    shared_except "scroll"  "locked" { bind "Ctrl g" { SwitchToMode "Scroll"; } }
    shared_except "session" "locked" { bind "Ctrl s" { SwitchToMode "Session"; } }
    shared_except "tab"     "locked" { bind "Ctrl t" { SwitchToMode "Tab"; } }
    shared_except "move"    "locked" { bind "Ctrl b" { SwitchToMode "Move"; } }
    shared_except "tmux"    "locked" {
        // disabled — I don't use tmux mode
    }
}

plugins {
    tab-bar         location="zellij:tab-bar"
    status-bar      location="zellij:status-bar"
    strider         location="zellij:strider"
    compact-bar     location="zellij:compact-bar"
    session-manager location="zellij:session-manager"
    welcome-screen  location="zellij:session-manager" {
        welcome_screen true
    }
    filepicker location="zellij:strider" {
        cwd "/"
    }
}

default_shell "zsh"

// I turn frames off — saves a row and a column per pane. The status
// bar still shows which pane is focused.
pane_frames false

themes {
    custom {
        fg      64  64  64
        bg      64  64  64
        black   0   0   0
        red     168 0   0
        green   96  128 96
        yellow  255 255 0
        blue    0   0   168
        magenta 168 0   96
        cyan    0   96  168
        white   168 168 168
        orange  168 64  0
    }
}

theme "custom"
```

### Notes on the keymap

- **`shared_except` blocks** are how Zellij lets you define a binding that works in every mode *except* some list. I use them so `Ctrl k` always enters pane mode, `Ctrl t` always enters tab mode, etc., regardless of what mode I'm in — no more "chain `Ctrl g` to exit, then `Ctrl p` to enter."
- **`Alt`-based quick movement** (`Alt h/j/k/l`, `Alt n`, `Alt =/-`) works from any non-locked mode. This is the one I use most — I rarely need to formally enter pane or resize mode.
- **Lock mode** (`Ctrl l`) passes every key through to the underlying app. Essential when using an editor that wants `Ctrl` bindings of its own.
- **Tmux mode is disabled** intentionally — I don't want `Ctrl b` grabbed.

## Layouts

Two layouts, both minimal. Zellij's default tab bar + status bar are both one-liners, so I just stack them with a working area in between.

`~/.config/zellij/layout.kdl` — the default:

```kdl
layout {
    pane size=1 borderless=true {
        plugin location="zellij:compact-bar"
    }
    pane
    pane size=1 borderless=true {
        plugin location="zellij:status-bar"
    }
}
```

`~/.config/zellij/layout_full.kdl` — same thing but with a 2-row status bar (shows mode hints):

```kdl
layout {
    pane size=1 borderless=true {
        plugin location="zellij:compact-bar"
    }
    pane
    pane size=2 borderless=true {
        plugin location="zellij:status-bar"
    }
}
```

I default to the compact one and only open the "full" layout when I need a reminder of what's bound where.

## Shell integration

```sh
alias z=zellij
alias zt='zellij action new-tab --layout ~/.config/zellij/layout_full.kdl'
```

And for zsh, a completion hookup so `z<TAB>` completes zellij subcommands:

```sh
compdef z=zellij 2>/dev/null
```

## Terminal emulator integration

I have my terminal emulator launch Zellij directly as its command, so opening a new terminal window = new Zellij session. Example for Alacritty:

```toml
shell = { program = "sh", args = [
  "-c",
  "zellij --layout ~/.config/zellij/layout.kdl || zsh",
] }
```

The `|| zsh` fallback means if Zellij fails to start (e.g. not installed), I still get a usable shell.

## Install

```sh
mkdir -p ~/.config/zellij
install -m 644 zellij_config.kdl       ~/.config/zellij/config.kdl
install -m 644 zellij_layout.kdl       ~/.config/zellij/layout.kdl
install -m 644 zellij_layout_full.kdl  ~/.config/zellij/layout_full.kdl
```

## Things I'd change / known rough edges

- **Filepicker launch** (`Alt f` → `LaunchPlugin "filepicker"`) crashed Zellij last I tried, so it's commented out. Might be fixed now.
- **Copy command** isn't set — I rely on OSC 52 passthrough from my terminal. If your terminal doesn't support OSC 52 you'll want `copy_command "wl-copy"` / `"xclip -selection clipboard"` / `"pbcopy"`.
- **`copy_on_select`** is left at the default (true). Fine for me; if you use `Alt c`-style copy you'd flip this.
