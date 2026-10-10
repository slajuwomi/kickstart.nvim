# Neovim Configuration Guide

A comprehensive guide to using this Neovim setup. Designed for developers who are
new to Neovim or want to get the most out of this configuration.

---

## Table of Contents

1. [Vim Survival Skills](#1-vim-survival-skills)
2. [Overview of This Config](#2-overview-of-this-config)
3. [Plugin Manager: lazy.nvim](#3-plugin-manager-lazynvim)
4. [Telescope: The Fuzzy Finder](#4-telescope-the-fuzzy-finder)
5. [LSP: Go to Definition, References, Rename, etc.](#5-lsp-language-server-protocol)
6. [Autocompletion with blink.cmp](#6-autocompletion-with-blinkcmp)
7. [Auto-formatting with conform.nvim](#7-auto-formatting-with-conformnvim)
8. [Git Integration with gitsigns](#8-git-integration-with-gitsigns)
9. [Surround, Text Objects, and Statusline (mini.nvim)](#9-mininvim--surround-text-objects-statusline)
10. [Syntax Highlighting with Treesitter](#10-syntax-highlighting-with-treesitter)
11. [Keybinding Discovery with which-key](#11-keybinding-discovery-with-which-key)
12. [Todo Comments Highlighting](#12-todo-comments)
13. [Tmux Integration](#13-tmux-integration)
14. [Wakatime Time Tracking](#14-wakatime-time-tracking)
15. [Built-in Terminal](#15-built-in-terminal)
16. [Disabled Plugins (How to Enable Them)](#16-disabled-plugins-how-to-enable-them)
17. [Advanced Vim Techniques](#17-advanced-vim-techniques)
18. [Customizing This Config](#18-customizing-this-config)
19. [Troubleshooting & Maintenance](#19-troubleshooting--maintenance)
20. [Quick Reference: All Keybindings](#20-quick-reference-all-keybindings)

---

## 1. Vim Survival Skills

If you are completely new to Vim/Neovim, run the built-in tutor first:

```
nvim
:Tutor
```

This interactive tutorial takes about 30 minutes and teaches the fundamentals. Do it.

### 1.1 Modes

Vim is a **modal** editor. The same key does different things in different modes.

| Mode | How to Enter | Purpose |
|------|-------------|---------|
| **Normal** | Press `<Esc>` | Navigate, delete, copy, execute commands. This is your home base. |
| **Insert** | `i`, `a`, `o`, `O` | Type text. `i` inserts before cursor, `a` after, `o` opens new line below. |
| **Visual** | `v`, `V`, `Ctrl-v` | Select text. `v` for character-wise, `V` for line-wise, `Ctrl-v` for block. |
| **Command-line** | `:`, `/`, `?` | Run commands (`:`), search forward (`/`), search backward (`?`). |
| **Replace** | `R` | Overwrite text (rarely used). |

**The golden rule:** Stay in Normal mode. Only enter Insert mode to type, then
immediately press `<Esc>` to go back.

### 1.2 Basic Movement (Normal mode)

| Keys | Action |
|------|--------|
| `h` / `j` / `k` / `l` | Left / Down / Up / Right |
| `w` / `b` | Next word forward / backward |
| `e` / `ge` | End of next word / End of previous word |
| `0` / `^` / `$` | Start of line / First non-blank char / End of line |
| `gg` / `G` | Go to first line / Go to last line |
| `{number}G` | Go to line number (e.g. `42G` goes to line 42) |
| `Ctrl-d` / `Ctrl-u` | Scroll down / up half a page |
| `Ctrl-f` / `Ctrl-b` | Page down / page up (forward/backward) |
| `%` | Jump to matching bracket/paren/brace |
| `{` / `}` | Jump to previous / next blank line (paragraph) |

### 1.3 Basic Editing (Normal mode)

| Keys | Action |
|------|--------|
| `i` / `a` | Insert before / after cursor |
| `I` / `A` | Insert at beginning / end of line |
| `o` / `O` | Open new line below / above |
| `x` | Delete character under cursor |
| `dd` | Delete (cut) current line |
| `yy` | Yank (copy) current line |
| `p` / `P` | Paste after / before cursor |
| `u` / `Ctrl-r` | Undo / Redo |
| `>>` / `<<` | Indent / un-indent line |
| `.` | Repeat last change |
| `~` | Toggle case of character under cursor |
| `r{char}` | Replace character under cursor with `{char}` |

### 1.4 The Operator + Motion Grammar

This is the most powerful Vim concept. Most commands follow this pattern:

```
{operator}{count}{motion}
```

Examples:
- `d3w` — **Delete** 3 **words**
- `c$` — **Change** (delete + enter insert) to **end of line**
- `yap` — **Yank** a **paragraph**
- `d%` — **Delete** to **matching bracket**
- `>3j` — **Indent** the next 3 **lines down**
- `gu$` — **Lowercase** to **end of line**

| Operator | Meaning |
|----------|---------|
| `d` | Delete |
| `c` | Change (delete + insert mode) |
| `y` | Yank (copy) |
| `>` | Indent |
| `<` | Un-indent |
| `gu` / `gU` | Lowercase / Uppercase |
| `g~` | Toggle case |

### 1.5 Search and Replace

| Keys | Action |
|------|--------|
| `/pattern` | Search forward for `pattern` |
| `?pattern` | Search backward for `pattern` |
| `n` / `N` | Next / Previous match |
| `*` / `#` | Search forward/backward for word under cursor |
| `<Esc>` | Clear search highlights |
| `:%s/old/new/g` | Replace all occurrences of `old` with `new` in file |
| `:%s/old/new/gc` | Same, but confirm each replacement |

The `%` means the whole file. Replace `%` with `1,10` for lines 1-10. The `g`
flag replaces all occurrences on each line. The `c` flag asks for confirmation.
In this config, `inccommand` is set to `split`, so you see a live preview of
substitutions as you type the command.

### 1.6 Windows and Splits

| Keys | Action |
|------|--------|
| `:split` / `:sp` | Horizontal split |
| `:vsplit` / `:vs` | Vertical split |
| `:split file.txt` | Open `file.txt` in a horizontal split |
| `Ctrl-w h/j/k/l` | Move focus left/down/up/right |
| `Ctrl-w q` | Close current window |
| `Ctrl-w =` | Equalize window sizes |
| `Ctrl-w _` | Maximize height |
| `Ctrl-w \|` | Maximize width |

**This config** uses `<C-h/j/k/l>` (Ctrl+h/j/k/l) directly — no `Ctrl-w` prefix
needed. So `<C-h>` moves to the left window, `<C-j>` down, etc.

New splits open to the right (`splitright`) and below (`splitbelow`).

### 1.7 Buffers vs Tabs vs Windows

- **Buffer**: An open file in memory. You can have many buffers but view only a few.
- **Window**: A viewport onto a buffer. You can split windows and view different
  parts of the same buffer or different buffers.
- **Tab**: A collection of windows. Think of it as a workspace layout.

Key buffer commands:
| Keys | Action |
|------|--------|
| `:e file.txt` | Edit (open) `file.txt` |
| `:bnext` / `:bn` | Next buffer |
| `:bprev` / `:bp` | Previous buffer |
| `:bd` | Delete (close) buffer |
| `:ls` | List all buffers |
| `<leader><leader>` | Find existing buffers with Telescope (see Section 4) |

### 1.8 The Leader Key

The **leader key** is a prefix for custom shortcuts. In this config, it is
`<Space>`. So when you see `<leader>sf`, it means: press Space, then s, then f.

You will see the available leader key bindings pop up as a menu when you press
`<Space>` and wait a moment (thanks to which-key, see Section 11).

---

## 2. Overview of This Config

### 2.1 What This Is

This config is based on **[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)**,
a popular Neovim starter template. It has been customized with:

- **Colorscheme:** Gruvbox dark (hard contrast)
- **Font:** Plain Unicode text (no Nerd Font required for basic usage, though icons will look better with one)
- **Language focus:** Go is fully configured (gopls LSP, goimports formatter, Delve debugger ready to enable)
- **Clipboard:** Shared with the OS (copy in terminal copies to system clipboard)

### 2.2 Plugins at a Glance

| Plugin | What It Does |
|--------|-------------|
| **lazy.nvim** | Plugin manager |
| **Telescope** | Fuzzy finder: files, text, symbols, help, diagnostics |
| **nvim-lspconfig + Mason** | LSP support: go-to-definition, references, rename, etc. |
| **blink.cmp** | Autocompletion with LSP, paths, and snippets |
| **LuaSnip** | Snippet engine |
| **conform.nvim** | Auto-formatting on save |
| **gitsigns** | Git gutter indicators (added/changed/deleted lines) |
| **which-key** | Shows available keybindings as you type |
| **mini.nvim** | Surround (`sa`, `sd`, `sr`), better text objects (`mini.ai`), statusline |
| **Treesitter** | Better syntax highlighting and indentation |
| **todo-comments** | Highlights `TODO`, `FIXME`, `HACK`, etc. in comments |
| **gruvbox** | Retro dark colorscheme |
| **guess-indent** | Auto-detects indentation settings per file |
| **vim-tmux-navigator** | Seamless `Ctrl-hjkl` navigation between Neovim and tmux panes |
| **wakatime** | Time tracking (disabled via `enabled = false`) |
| **lazydev** | Lua LSP for Neovim config/plugins |
| **hardtime.nvim** | Hints faster keys when you repeat slow patterns (`jjjj` → `4j`); `:Hardtime report` lists your habits |
| **keyhints** (custom, `lua/custom/keyhints.lua`) | Box in the top-right showing useful keys for what's under the cursor and the current mode; off by default, toggle `<leader>tk` |

### 2.3 Languages Configured

- **Go**: Fully configured (gopls LSP + goimports formatter)
- **Lua**: Fully configured (lua_ls LSP + stylua formatter)
- **HTML/CSS**: Fully configured (html + cssls + emmet_ls LSP)
- **Python, Rust, TypeScript, C/C++**: LSP configs exist but are commented out. Uncomment in `init.lua` to enable them.
- **Bash, Markdown, JSON, YAML**: Treesitter syntax highlighting only (no dedicated LSP).

---

## 3. Plugin Manager: lazy.nvim

### 3.1 Plugin Dashboard

```
:Lazy
```

Opens the plugin dashboard. From here you can:
- See all installed plugins and their status
- Press `?` for help on available keybindings in the dashboard
- Press `q` to close

### 3.2 Useful Commands

| Command | What It Does |
|---------|-------------|
| `:Lazy` | Open plugin dashboard |
| `:Lazy sync` | Sync all plugins (install missing, update to lockfile versions, clean unused) |
| `:Lazy update` | Update all plugins to latest |
| `:Lazy update {plugin}` | Update a specific plugin |
| `:Lazy clean` | Remove unused plugins |
| `:Lazy restore` | Restore plugins to lockfile versions |
| `:Lazy profile` | Profile startup time |
| `:Lazy log` | Show lazy.nvim log |
| `:Lazy debug` | Debug lazy loading issues |

### 3.3 Plugin Lockfile

The `lazy-lock.json` file pins exact plugin versions. When you run `:Lazy sync`,
it installs/updates plugins to match this file. Run `:Lazy update` to bump
plugins to latest and update the lockfile.

---

## 4. Telescope: The Fuzzy Finder

Telescope is the most important plugin in this config. It replaces the file
browser, buffer switcher, grep tool, symbol browser, and more — all with a
single fuzzy-finding interface.

### 4.1 All Telescope Keybindings

All Telescope search commands start with `<leader>s` (Space + s). Press
`<space>` and wait a moment — which-key will show the `[S]earch` menu.

| Keys | What It Does |
|------|-------------|
| `<leader>sf` | **Find Files** — fuzzy search filenames in your project |
| `<leader>sg` | **Live Grep** — search file *contents* across your whole project with regex |
| `<leader>sh` | **Search Help** — search Neovim's built-in help docs |
| `<leader>sk` | **Search Keymaps** — find keybindings by description |
| `<leader>ss` | **Select Telescope Builtin** — browse all Telescope search types |
| `<leader>sw` | **Search current Word** — grep for the word under cursor |
| `<leader>sd` | **Search Diagnostics** — browse LSP errors/warnings across the project |
| `<leader>sr` | **Resume** — reopen your last Telescope picker |
| `<leader>s.` | **Recent Files** — fuzzy search recently opened files |
| `<leader>sn` | **Search Neovim files** — search files in your Neovim config directory |
| `<leader>/` | **Fuzzy find in current buffer** — search within the current file |
| `<leader>s/` | **Search in Open Files** — grep only across your open buffers |
| `<leader><leader>` | **Find existing buffers** — switch between open files |

### 4.2 How to Use Telescope

1. Press `<leader>sf` to find files.
2. Start typing — Telescope fuzzy-matches filenames as you type.
3. Use `Ctrl-n` / `Ctrl-p` (or arrow keys) to move up/down the list.
4. Press `<CR>` (Enter) to open the selected file.
5. Press `Ctrl-t` to open in a new tab, `Ctrl-v` for vertical split, `Ctrl-x` for horizontal split.

**Pro tips:**
- To search the **entire project** for a string, use `<leader>sg` (Live Grep).
  This is powered by **[ripgrep](https://github.com/BurntSushi/ripgrep)** which
  must be installed on your system.
- Use `<leader>sr` to bring back your last search without retyping.
- In any Telescope picker, press `?` (Normal mode) or `Ctrl-/` (Insert mode) to
  see all available keybindings for that picker.
- You can chain searches: `<leader>sg`, search for something, then
  `<leader>sr` to come back to it.
- `<leader>/` opens a dropdown for searching within the current file — great
  for navigating large files.
- `<leader><leader>` lets you quickly switch between open buffers.

### 4.3 Telescope for Git

| Keys | What It Does |
|------|-------------|
| `:Telescope git_files` | Find files tracked by git |
| `:Telescope git_status` | Browse files with uncommitted changes |
| `:Telescope git_branches` | Switch git branches |
| `:Telescope git_commits` | Browse commit history |
| `:Telescope git_bcommits` | Browse commits for current buffer |

### 4.4 Telescope for LSP (also accessible via `gr` prefix)

| Keys | What It Does |
|------|-------------|
| `:Telescope lsp_references` | Find all references to symbol under cursor |
| `:Telescope lsp_definitions` | Go to definition |
| `:Telescope lsp_implementations` | Go to implementation |
| `:Telescope lsp_type_definitions` | Go to type definition |
| `:Telescope lsp_document_symbols` | Browse symbols in current file |
| `:Telescope lsp_dynamic_workspace_symbols` | Browse symbols in entire project |
| `:Telescope diagnostics` | Browse all diagnostics in project |

---

## 5. LSP (Language Server Protocol)

LSP gives you IDE-like features: go-to-definition, find-references, rename,
hover info, diagnostics, code actions, and more.

### 5.1 LSP Installation

When you open a file for the first time, Mason automatically installs the
required language server. You can also manage servers manually:

```
:Mason
```

This opens the Mason UI where you can:
- Press `g?` for help
- Press `i` to install a server, `X` to uninstall, `U` to update
- Browse available servers, linters, formatters, and debuggers

Currently configured LSP servers:
- **gopls** (Go)
- **lua_ls** (Lua)
- **html** (HTML)
- **cssls** (CSS)
- **emmet_ls** (Emmet for HTML/CSS/JSX)

Additional servers like `pyright`, `rust_analyzer`, `ts_ls`, and `clangd` are
commented out in the config. Uncomment them to enable (see Section 18).

### 5.2 LSP Keybindings

All LSP keybindings start with `gr` (think "**g**oto **r**eference"):

| Keys | Action |
|------|--------|
| `grd` | **Go to Definition** — jump to where the symbol is defined |
| `grD` | **Go to Declaration** — jump to the declaration (e.g., header file in C) |
| `grr` | **Go to References** — find all usages of the symbol (opens Telescope) |
| `gri` | **Go to Implementation** — jump to interface/concrete implementation |
| `grt` | **Go to Type Definition** — jump to the type definition |
| `grn` | **Rename** — rename the symbol across the entire project |
| `gra` | **Code Action** — show available fixes (e.g., auto-import, extract function) |
| `gO` | **Document Symbols** — browse functions, variables, types in current file |
| `gW` | **Workspace Symbols** — search all symbols across the entire project |
| `<leader>th` | **Toggle Inlay Hints** — show/hide inline type hints |

**Important navigation tricks:**
- After using `grd`, use `Ctrl-t` to jump back to where you were.
- After `grr`, you can navigate the Telescope results and press Enter to jump.
- `Ctrl-o` (go back) and `Ctrl-i` (go forward) work across all jumps, not just LSP.

### 5.3 Diagnostics (Errors and Warnings)

Errors and warnings appear as:
- Inline text (virtual text) next to the problematic line
- Underlines under ERROR-level issues
- Available in the sign column (left gutter)

| Keys | Action |
|------|--------|
| `<leader>q` | Open the diagnostic quickfix list (navigate errors with `j`/`k`, press Enter) |
| `[d` / `]d` | Jump to previous / next diagnostic (built-in Neovim, not mapped by this config) |
| `<leader>sd` | Search diagnostics across project with Telescope |

To see diagnostic details, put your cursor on the problematic line and the
diagnostic message appears in a floating window after a short delay. You can also
hover intentionally with `K` (in normal mode).

### 5.4 LSP Features While You Type

- **Document highlight:** When you rest your cursor on a symbol, all references
  to it in the current file are highlighted.
- **Signature help:** When typing function arguments, the function signature
  appears automatically.
- **Auto-formatting:** On save, your code is formatted (see Section 7).

---

## 6. Autocompletion with blink.cmp

`blink.cmp` provides IDE-style autocompletion as you type, pulling from LSP
servers, file paths, and snippets.

### 6.1 Completion Sources (Priority Order)

1. **LSP** — Language server suggestions (most relevant)
2. **Path** — File path completions (handy for imports/file references)
3. **Snippets** — LuaSnip snippets
4. **lazydev** — Neovim API completions for Lua config files

### 6.2 Completion Keybindings

| Keys | Action |
|------|--------|
| `Ctrl-n` / `Ctrl-p` | Next / Previous completion item |
| `Ctrl-y` | **Accept** completion (this auto-imports if your LSP supports it) |
| `Ctrl-e` | Dismiss the completion menu |
| `Ctrl-Space` | Open the completion menu manually / Open documentation |
| `Ctrl-k` | Toggle signature help (shows function parameters) |
| `Tab` / `Shift-Tab` | Move to next/previous snippet placeholder |

When a completion is accepted with `Ctrl-y`:
- If the LSP provides auto-import, the import is added automatically.
- If the completion is a snippet, you can tab through the placeholders.

### 6.3 Snippets

This config uses **LuaSnip** v2 as the snippet engine. Friendly-snippets
(a pre-made snippet library) is commented out by default. To enable it, see
Section 18.

You can also define your own snippets. Create files under
`~/.config/nvim/lua/custom/plugins/snippets.lua` or use the
LuaSnip API directly.

---

## 7. Auto-formatting with conform.nvim

### 7.1 Format on Save

Your code is **automatically formatted** every time you save a file. This works
for:

| Language | Formatter |
|----------|-----------|
| **Lua** | stylua |
| **Go** | goimports (organizes imports + formats) |
| **Other** | Falls back to LSP formatting if available |

C and C++ files have format-on-save **disabled** by default (their coding styles
are less standardized).

### 7.2 Manual Formatting

| Keys | Action |
|------|--------|
| `<leader>f` | Format the current buffer immediately |

### 7.3 Formatter Info

```
:ConformInfo
```

Shows which formatters are available and configured for the current file.

### 7.4 Adding More Formatters

Edit the `formatters_by_ft` table in `init.lua` (lines 784-792). The commented-out
examples show how to add Python (`isort` + `black`) and JavaScript
(`prettierd` / `prettier`) formatters. Mason can install formatters — search
`:Mason` for available ones.

---

## 8. Git Integration with gitsigns

### 8.1 Gutter Indicators

This config uses simplified text symbols in the left gutter:

| Symbol | Meaning |
|--------|---------|
| `+` | Added line |
| `~` | Changed line |
| `_` | Deleted line |

These appear automatically for files tracked by git.

### 8.2 Gitsigns Commands (Command-line)

Since the extended gitsigns keymaps are commented out by default, you can use
command-line commands:

| Command | What It Does |
|---------|-------------|
| `:Gitsigns stage_hunk` | Stage the hunk under cursor |
| `:Gitsigns reset_hunk` | Reset the hunk under cursor |
| `:Gitsigns preview_hunk` | Preview the change under cursor |
| `:Gitsigns blame_line` | Show git blame for current line |
| `:Gitsigns diffthis` | Show diff of current buffer |
| `:Gitsigns toggle_current_line_blame` | Toggle inline blame |

### 8.3 Enabling Extended Gitsigns Keymaps

The file `lua/kickstart/plugins/gitsigns.lua` contains convenient keybindings
for git operations. To enable them, uncomment this line near the end of
`init.lua`:

```lua
require 'kickstart.plugins.gitsigns',
```

Then restart Neovim. You'll get these keybindings (all in normal mode):

| Keys | Action |
|------|--------|
| `]c` / `[c` | Next / Previous git change |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage entire buffer |
| `<leader>hR` | Reset entire buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line (shows who changed this line) |
| `<leader>hd` | Diff against index (staged changes) |
| `<leader>hD` | Diff against last commit |
| `<leader>tb` | Toggle inline git blame |
| `<leader>tD` | Toggle deleted lines preview |

---

## 9. mini.nvim — Surround, Text Objects, Statusline

This config loads three modules from the `mini.nvim` collection:

### 9.1 mini.surround — Add, Delete, Replace Surroundings

These are extremely useful for editing code. The format is:

- `sa{motion}{char}` — **S**urround **A**dd
- `sd{char}` — **S**urround **D**elete
- `sr{char}{char}` — **S**urround **R**eplace

| Keys | Action |
|------|--------|
| `saw)` | Add parentheses around the current word |
| `saW{` | Add braces around the WORD (including punctuation) |
| `sa2w"` | Add double-quotes around the next 2 words |
| `sd'` | Delete surrounding single quotes |
| `sd(` | Delete surrounding parentheses |
| `sd"` | Delete surrounding double quotes |
| `sr"'` | Replace surrounding double quotes with single quotes |
| `sr(` (then type `[`) | Replace parentheses with square brackets |

In **visual mode**, you can also:
1. Select some text with `v` or `V`.
2. Press `S` (capital S).
3. Type the character you want to wrap around the selection `(`, `"`, `{`, etc.

### 9.2 mini.ai — Better Text Objects

`mini.ai` enhances the built-in `a` (around) and `i` (inside) text objects.

| Standard text objects already work | What they do |
|------------------------------------|-------------|
| `ciw` | Change inside word |
| `di"` | Delete inside double quotes |
| `ya(` | Yank around parentheses |
| `vi{` | Visually select inside braces |

`mini.ai` adds **n**, **l** submodes for more flexibility:

| Keys | Action |
|------|--------|
| `cinq` | Change inside next quote |
| `vil"` | Visually select inside last double quotes |
| `dan]` | Delete around next square brackets |
| `yil(` | Yank inside last parentheses |

The `n` targets the *next* occurrence and `l` targets the *last* occurrence.

### 9.3 mini.statusline

A simple, minimal statusline at the bottom showing:
- File info (path, modified indicator)
- Cursor position (LINE:COLUMN format)
- File type

It is purposely minimal. If you want a richer statusline, you can replace it
with something like `nvim-lualine/lualine.nvim`.

---

## 10. Syntax Highlighting with Treesitter

Treesitter provides **precise, semantic syntax highlighting** — much better than
Vim's regex-based highlighting. It understands the actual structure of your code.

### 10.1 Languages with Treesitter Support

These parsers are pre-installed: `bash`, `c`, `diff`, `html`, `lua`, `luadoc`,
`markdown`, `markdown_inline`, `query`, `vim`, `vimdoc`.

`auto_install = true` means Treesitter automatically installs parsers for any
new language you open.

### 10.2 What Treesitter Gives You

- **Better syntax highlighting** for supported languages
- **Better indentation** — understands code structure, not just regex rules
- **Incremental selection** — expand/shrink selection by syntax nodes
- **Code folding** — fold functions, classes, if-blocks

### 10.3 Manual Parser Management

| Command | What It Does |
|---------|-------------|
| `:TSInstall {lang}` | Install parser for `{lang}` (e.g., `:TSInstall python`) |
| `:TSUpdate` | Update all installed parsers |
| `:TSUninstall {lang}` | Remove parser for `{lang}` |
| `:TSModuleInfo` | Show status of all parsers |
| `:InspectTree` | Open the syntax tree (debugging) |

### 10.4 Recommended Add-ons (Not Installed)

These popular Treesitter companion plugins are worth exploring:
- **nvim-treesitter-context** — Shows the current function/class at the top of the window
- **nvim-treesitter-textobjects** — Adds `function`, `class`, `loop` text objects

---

## 11. Keybinding Discovery with which-key

**which-key** shows a popup of available keybindings whenever you pause after a
partial key sequence. This is incredibly helpful for discovering what you can do.

### 11.1 How It Works

1. Press `<Space>` (the leader key) and wait a moment.
2. A popup appears showing all available leader key groups: `[S]earch`, `[T]oggle`, `Git [H]unk`.
3. Press `s` to see all search keybindings.
4. The popup updates to show: `h` Help, `k` Keymaps, `f` Files, `g` Grep, etc.

This works for **any** key prefix, not just `<leader>`. Try pressing `g` and
waiting — you'll see all `g`-prefixed commands.

### 11.2 Which-key Delay

The popup appears with a `delay = 0`, meaning it shows immediately. This is
different from `timeoutlen` (300ms), which controls how long Neovim waits for
you to finish a key sequence before treating it as incomplete.

---

## 12. Todo Comments

The `todo-comments.nvim` plugin highlights special keywords in your code comments:

| Keyword | Color | Use For |
|---------|-------|---------|
| `TODO` | Blue | Things to do |
| `FIXME` | Red | Things that are broken |
| `HACK` | Yellow | Workarounds that need revisiting |
| `WARN` | Orange | Warnings for future readers |
| `PERF` | Purple | Performance improvements |
| `NOTE` | Green | Important notes |
| `TEST` | Cyan | Testing-related notes |

Additionally, you can search all TODO-style comments with:
- `:TodoTelescope` — Fuzzy search all todos in your project (requires Telescope)

The highlight color depends on the keyword. Simply write `TODO: fix this later`
in a comment and it will stand out.

---

## 13. Tmux Integration

The `vim-tmux-navigator` plugin seamlessly moves between Neovim splits and
tmux panes using the same `Ctrl-hjkl` keys.

### 13.1 Navigation

| Keys | Where It Goes |
|------|--------------|
| `Ctrl-h` | Move focus left (Neovim split OR tmux pane) |
| `Ctrl-j` | Move focus down |
| `Ctrl-k` | Move focus up |
| `Ctrl-l` | Move focus right |

This works automatically — you don't need to think about whether you're moving
within Neovim or to an adjacent tmux pane. The plugin figures it out.

### 13.2 Setup Requirement

For this to work, you must also configure your tmux to use the same keys. Add
the recommended config from the [vim-tmux-navigator README](https://github.com/christoomey/vim-tmux-navigator)
to your `~/.tmux.conf`.

---

## 14. Wakatime Time Tracking

`wakatime/vim-wakatime` tracks time spent coding. It is currently **disabled**
(`enabled = false` in its spec in `init.lua`). Remove that line to turn it back on.

You must configure your Wakatime API key. Create or edit `~/.wakatime.cfg`:

```ini
[settings]
api_key = YOUR_API_KEY_HERE
```

If you don't use Wakatime, you can remove the plugin spec from `init.lua`.

---

## 15. Built-in Terminal

Neovim has a built-in terminal emulator.

### 15.1 Opening a Terminal

| Command | What It Does |
|---------|-------------|
| `:terminal` | Open terminal in a split |
| `:vert terminal` | Open terminal in a vertical split |
| `:terminal {cmd}` | Run a specific command (e.g., `:terminal go test ./...`) |

### 15.2 Terminal Mode vs Normal Mode

When in a terminal split:
- You are in **Terminal mode** by default — keystrokes go to the shell.
- Press `<Esc><Esc>` to enter **Normal mode** (so you can scroll, copy, etc.).
- Press `i` or `a` to go back to Terminal mode.
- In this config, `<Esc><Esc>` exits terminal mode (simpler than the default `<Ctrl-\><Ctrl-n>`).

### 15.3 Terminal Tips

- Use `<C-w>h/j/k/l` or `<C-h/j/k/l>` to leave the terminal window while
  staying in Normal mode.
- In Normal mode in a terminal, you can use all Vim navigation (`gg`, `/`, `yy`, etc.)
- Run `:terminal` and then `:bdelete!` to close it when done.

---

## 16. Disabled Plugins (How to Enable Them)

Several plugins have pre-written configuration files that are **commented out**
in `init.lua`. To enable them, find the relevant line near the bottom of
`init.lua` (around line 1003) and uncomment it.

### 16.1 Debugging with DAP (Delphi/DAP for Go)

Uncomment this line:
```lua
require 'kickstart.plugins.debug',
```

This enables the Go debugger (Delve) with its keybindings:

| Keys | Action |
|------|--------|
| `<F5>` | Start / Continue debugging |
| `<F1>` | Step into |
| `<F2>` | Step over |
| `<F3>` | Step out |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Set conditional breakpoint |
| `<F7>` | Toggle DAP UI (variables, call stack, watches) |

To use it: set a breakpoint with `<leader>b`, then press `<F5>`. The DAP UI
auto-opens showing variables and call stack.

### 16.2 Neo-tree File Browser

Uncomment this line:
```lua
require 'kickstart.plugins.neo-tree',
```

Adds a sidebar file browser like VSCode's explorer:
- `\` reveals the current file in Neo-tree
- `\` pressed inside the tree closes it

### 16.3 Indent Guide Lines

Uncomment this line:
```lua
require 'kickstart.plugins.indent_line',
```

Shows vertical lines at each indentation level, making nested code easier to read.

### 16.4 Auto-pairs

Uncomment this line:
```lua
require 'kickstart.plugins.autopairs',
```

Auto-closes brackets, quotes, etc. as you type. Typing `(` auto-inserts `)`.

### 16.5 Linting (nvim-lint)

Uncomment this line:
```lua
require 'kickstart.plugins.lint',
```

Enables `markdownlint` for Markdown files. You can extend it with other
linters (ESLint, flake8, etc.).

### 16.6 Extended Gitsigns Keymaps

Uncomment this line:
```lua
require 'kickstart.plugins.gitsigns',
```

Enables all the gitsigns keybindings detailed in Section 8.3.

---

## 17. Advanced Vim Techniques

### 17.1 Text Objects (Built-in)

Text objects are the `i` (inside) and `a` (around) modifiers. Combined with
operators, they are incredibly powerful:

| Command | What It Does |
|---------|-------------|
| `ci"` | Change inside double quotes |
| `ci(` | Change inside parentheses |
| `ci{` | Change inside braces |
| `cit` | Change inside HTML/XML tag |
| `da(` | Delete around parentheses (delete parens too) |
| `ya{` | Yank around braces |
| `viw` | Visually select inside word |
| `vap` | Visually select around paragraph |

### 17.2 Marks

Marks let you save positions and jump back to them.

| Command | What It Does |
|---------|-------------|
| `m{a-z}` | Set a local mark (e.g., `ma` saves position to mark `a`) |
| `'{a-z}` | Jump to the line of mark `{a-z}` |
| `` `{a-z} `` | Jump to the exact column of mark `{a-z}` |
| `m{A-Z}` | Set a global mark (works across files) |
| `:marks` | List all marks |
| `''` | Jump back to last jump position |
| `'` (then `'` again) | Jump back to last jump position (shorthand) |

### 17.3 Macros

Record and replay sequences of commands.

| Command | What It Does |
|---------|-------------|
| `q{a-z}` | Start recording macro to register `{a-z}` |
| `q` | Stop recording |
| `@ {a-z}` | Play back macro from register `{a-z}` |
| `@@` | Replay last macro |
| `5@a` | Play macro `a` 5 times |

### 17.4 Registers

Registers store yanked/deleted text and macros.

| Command | What It Does |
|---------|-------------|
| `"ayy` | Yank current line into register `a` |
| `"ap` | Paste from register `a` |
| `"+y` | Yank to system clipboard |
| `"+p` | Paste from system clipboard |
| `:reg` | List all registers and their contents |
| `"0p` | Paste the most recent yank (even after deleting) |

### 17.5 Quickfix List

The quickfix list is a list of locations (errors, search results, references).

| Command | What It Does |
|---------|-------------|
| `:copen` | Open the quickfix list window |
| `:cclose` | Close the quickfix list window |
| `:cnext` / `:cprev` | Go to next/previous item |
| `<leader>q` | Open diagnostic quickfix list (this config) |
| `:grep pattern %` | Add all matches of `pattern` in file to quickfix list |
| `:vimgrep /pattern/g **/*.go` | Search all `.go` files and populate quickfix list |

### 17.6 The Dot Command

The `.` (dot) command repeats your last change. This is one of the most powerful
Vim features.

- `dd` then `.` — delete another line
- `ciwnewname<Esc>` then `.` on another word — change it to `newname` too
- `>j` to indent a line, then `.` to indent the next one

Mastering `.` means you can do a complex edit once, then repeat it everywhere.

### 17.7 Jump List and Change List

| Command | What It Does |
|---------|-------------|
| `Ctrl-o` | Go to older position in jump list (go back) |
| `Ctrl-i` | Go to newer position in jump list (go forward) |
| `g;` | Go to older position in change list |
| `g,` | Go to newer position in change list |
| `:jumps` | List all jump positions |

### 17.8 Advanced Search Patterns

| Pattern | Meaning |
|---------|---------|
| `\v` | Very magic — use normal regex (recommended) |
| `\V` | Very nomagic — literal text (no regex) |
| `\c` | Case insensitive |
| `\C` | Case sensitive |
| `\<` / `\>` | Word boundary start/end |
| `\d` | Digit |
| `\s` | Whitespace |
| `\{n,m}` | Between n and m repetitions |

Example: `/\v<(foo|bar)\d+>` finds `foo123` or `bar42` as whole words.

---

## 18. Customizing This Config

### 18.1 Changing Settings

All settings are near the top of `init.lua` (lines 96-170). Common changes:

```lua
vim.o.relativenumber = true  -- uncomment to enable relative line numbers
vim.o.tabstop = 4             -- change tab width
vim.o.shiftwidth = 4          -- change indentation width
```

Use `<leader>sn` to quickly open your Neovim config for editing.

### 18.2 Adding Plugins

**Method 1: Add directly to init.lua**

Insert a new entry in the `require('lazy').setup({...})` block. Example:

```lua
{ 'tpope/vim-commentary', event = 'VeryLazy' },
```

**Method 2: Use the modular approach**

1. Create a file at `lua/custom/plugins/myplugin.lua`
2. Uncomment this line near the end of `init.lua`:
   ```lua
   { import = 'custom.plugins' },
   ```

This is the recommended approach as your config grows.

### 18.3 Adding LSP Servers

In `init.lua` at line 681, add your server:

```lua
local servers = {
  gopls = {},
  pyright = {},  -- uncomment or add
  rust_analyzer = {},  -- uncomment or add
}
```

Mason will automatically install it on the next Neovim start.

### 18.4 Adding Formatters

In the `conform.nvim` config (around line 784), add:

```lua
formatters_by_ft = {
  lua = { 'stylua' },
  go = { 'goimports' },
  python = { 'isort', 'black' },  -- add this
},
```

Then install the formatter via Mason (`:Mason`).

### 18.5 Adding Custom Keybindings

Add them after the plugin setup block. Example:

```lua
vim.keymap.set('n', '<leader>e', ':Explore<CR>', { desc = 'Open Netrw file explorer' })
```

The `desc` field makes it show up in which-key.

### 18.6 Changing the Colorscheme

The current colorscheme is gruvbox. To change it:

1. Add a new colorscheme plugin to the lazy.setup block.
2. Remove or comment out the gruvbox plugin entry.
3. Make sure the new colorscheme has `priority = 1000`.

---

## 19. Troubleshooting & Maintenance

### 19.1 First Aid

| Problem | Command |
|---------|---------|
| Something is broken | `:checkhealth` |
| Plugins not loading | `:Lazy` check for errors |
| LSP not working | `:LspInfo` see which servers are attached |
| Formatter not working | `:ConformInfo` check formatter status |
| Need to restart LSP | `:LspRestart` |
| Need to see errors | `:messages` shows recent messages |

### 19.2 Common Issues

**"Command not found" for LSP servers:**
Run `:Mason` and ensure the server is installed. If installed but not found,
Mason's binary directory may not be in your PATH. Add `~/.local/share/nvim/mason/bin`
to your PATH.

**Telescope live_grep says "rg: command not found":**
Install [ripgrep](https://github.com/BurntSushi/ripgrep): `brew install ripgrep` on macOS,
`sudo apt install ripgrep` on Ubuntu.

**Autocompletion not working:**
Check that an LSP is attached (`:LspInfo`). If no LSP, open a file of a
supported type (`.go`, `.lua`, `.html`) and Mason should install it. Run
`:Mason` to manually install the server if needed.

**Colors look wrong:**
Ensure `TERM` supports true color. For tmux, add to `~/.tmux.conf`:
```
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"
```
For iTerm2/Terminal.app, ensure "Report Terminal Type" is set to
`xterm-256color`.

### 19.3 Keeping Everything Updated

```vim
:Lazy update    " Update all plugins
:TSUpdate       " Update all Treesitter parsers
:Mason          " Then press U to update installed tools
```

### 19.4 Debugging Neovim Config

- `:Lazy profile` shows startup time for each plugin.
- `:Lazy debug` provides detailed loading information.
- Start nvim with `nvim --startuptime start.log` to get a detailed startup log.
- Use `:verbose map <key>` to see where a keybinding was set.

---

## 20. Quick Reference: All Keybindings

### 20.1 Window Navigation

| Keys | Action |
|------|--------|
| `<C-h>` | Move focus to left window |
| `<C-l>` | Move focus to right window |
| `<C-j>` | Move focus to lower window |
| `<C-k>` | Move focus to upper window |

### 20.2 Telescope (Fuzzy Finder)

| Keys | Action |
|------|--------|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep (search contents) |
| `<leader>sh` | Search help |
| `<leader>sk` | Search keymaps |
| `<leader>ss` | Select Telescope builtin |
| `<leader>sw` | Search current word |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Resume last search |
| `<leader>s.` | Recent files |
| `<leader>sn` | Search Neovim config files |
| `<leader>/` | Fuzzy find in current buffer |
| `<leader>s/` | Search in open files |
| `<leader><leader>` | Find existing buffers |

### 20.3 LSP (Code Intelligence)

| Keys | Action |
|------|--------|
| `grd` | Go to definition |
| `grD` | Go to declaration |
| `grr` | Find references |
| `gri` | Go to implementation |
| `grt` | Go to type definition |
| `grn` | Rename symbol |
| `gra` | Code action (fixes, refactors) |
| `gO` | Document symbols |
| `gW` | Workspace symbols |
| `<leader>th` | Toggle inlay hints |
| `<leader>q` | Open diagnostic quickfix list |

### 20.4 Formatting

| Keys | Action |
|------|--------|
| `<leader>f` | Format buffer |

### 20.5 Surround Operations (mini.surround)

| Keys | Action |
|------|--------|
| `sa{motion}{char}` | Add surroundings (e.g., `saw(` adds parens around word) |
| `sd{char}` | Delete surroundings (e.g., `sd'` removes quotes) |
| `sr{char}{char}` | Replace surroundings (e.g., `sr"'` replaces double with single quotes) |
| `S{char}` (visual) | Surround visual selection |

### 20.6 Text Objects

| Command | Action |
|---------|--------|
| `ciw` | Change inside word |
| `ci"` | Change inside quotes |
| `ci(` | Change inside parens |
| `di{` | Delete inside braces |
| `ya[` | Yank around brackets |
| `cin(` | Change inside next parens (`mini.ai` enhanced) |

### 20.7 Terminal Mode

| Keys | Action |
|------|--------|
| `<Esc><Esc>` | Exit terminal mode (to Normal mode) |
| `i` or `a` | Return to terminal mode from Normal mode |

### 20.8 Search

| Keys | Action |
|------|--------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` / `N` | Next / Previous match |
| `*` / `#` | Search for word under cursor |
| `<Esc>` | Clear search highlights |

### 20.9 General

| Keys | Action |
|------|--------|
| `<Esc>` | Clear search highlights |
| `u` / `Ctrl-r` | Undo / Redo |
| `Ctrl-o` / `Ctrl-i` | Jump back / forward |
| `%` | Jump to matching bracket |

### 20.10 Plugin Management

| Command | Action |
|---------|--------|
| `:Lazy` | Open plugin dashboard |
| `:Lazy update` | Update all plugins |
| `:Lazy sync` | Sync plugins to lockfile |
| `:Mason` | Manage LSP servers, formatters, linters |
| `:ConformInfo` | Show formatter info |
| `:TSUpdate` | Update Treesitter parsers |
| `:checkhealth` | Run health checks |

---

## Final Tips

1. **Run `:Tutor`** if you haven't already. It's 30 minutes well spent.
2. **Use `<leader>sh`** to search Neovim's built-in help — it's comprehensive and always available.
3. **Press `<Space>` and wait** to discover what you can do. which-key is your discovery tool.
4. **Use `<leader>sk`** to search keybindings by description.
5. **Use `Ctrl-o` frequently** to jump back after navigating to a definition.
6. **Don't use the mouse** for text editing — learn the keyboard motions. The mouse is fine
   for resizing splits or selecting Telescope items while you're learning.
7. **Learn one new Vim command per day** — there's always more to learn, but you don't
   need to learn it all at once.
8. **Read the config** — the `init.lua` file is heavily commented and explains why each
   plugin and setting is there. Use `<leader>sn` to jump to it quickly.

---

*This config is based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).
Read the `init.lua` file for more details on any setting or plugin.*
