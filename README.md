# Tetris

Classic terminal Tetris written entirely in [CLI Toolkit](https://github.com/oakulikov/clitool).

~600 lines of pure functional code. No external dependencies, no curses — just ANSI escape codes via `lib/term`.

## Install

**macOS / Linux:**

```bash
curl -sSL https://raw.githubusercontent.com/oakulikov/tetris/install.sh | bash
```

**Windows (WSL):**

Open Windows Terminal → Ubuntu/WSL tab, then run the same command:

```bash
curl -sSL https://raw.githubusercontent.com/oakulikov/tetris/install.sh | bash
```

Then just run `tetris`.

## Run from source

If you have clitool installed:

```bash
clitool examples/tetris/tetris.lang
```

Or build a standalone binary:

```bash
clitool build examples/tetris/tetris.lang -o tetris
./tetris
```

## Controls

| Key       | Action          |
|-----------|-----------------|
| `← →`    | Move left/right |
| `↑`      | Rotate          |
| `↓`      | Soft drop       |
| `Space`  | Hard drop       |
| `P`      | Pause / Resume  |
| `Enter`  | Start / Restart |
| `Q`      | Quit            |

## Features

- All 7 standard tetrominoes (I, O, T, S, Z, J, L) with 4 rotations each
- Wall kick on rotation
- Colored pieces (truecolor, 256-color, and basic 16-color support)
- Next piece preview
- Score, lines, and level tracking with session high score
- Increasing speed per level
- Line clear scoring (100 / 300 / 500 / 800 per 1–4 lines, scaled by level)
- Hard drop bonus (2 points per row)
- Start screen, pause overlay, game over screen
- Auto-centers in terminal window
- Flicker-free rendering via double-buffered output (`termBufferStart` / `termBufferFlush`)

## How It Works

The game is built on immutable state and tail-recursive game loop — no mutation, no variables reassigned in place.

**Game state** is a record with board grid, current/next piece, score, phase, etc. Every action (move, rotate, gravity tick) returns a new `GameState`:

```rust
type alias GameState = {
    board: List<List<Int>>,
    pieceKind: Int, pieceRot: Int,
    pieceRow: Int, pieceCol: Int,
    nextKind: Int,
    score: Int, lines: Int, level: Int,
    ...
}
```

**Game loop** is a single tail-recursive function:

```rust
fun gameLoop(st: GameState) -> GameState {
    key = readKey(30)
    st2 = processInput(st, key)
    st3 = processGravity(st2)
    render(st3)
    gameLoop(st3)
}
```

**Rendering** uses `cursorTo` for absolute positioning, colored blocks via `bgCyan`, `bgRed`, etc., and box-drawing characters for the board frame. The entire frame is buffered and flushed in a single write to avoid terminal flicker.

## Standard Library Used

| Package        | Functions                                                     |
|----------------|---------------------------------------------------------------|
| `lib/term`     | Raw input, cursor control, colors, buffered output            |
| `lib/time`     | `clockMs` for gravity timing                                  |
| `lib/list`     | `map`, `filter`, `foldl`, `range`                             |
| `lib/string`   | `stringRepeat`                                                |
| `lib/rand`     | `randomIntRange` for piece generation                         |
| `lib/sys`      | `sysExit`                                                     |

## Requirements

- macOS, Linux, FreeBSD, or Windows with [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
- Terminal with UTF-8 support
- Minimum 50×24 terminal size (auto-centers if larger)
