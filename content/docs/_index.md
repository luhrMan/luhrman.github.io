---
title: "Docs"
description: "How to use the Sqyre GUI, build macros from actions, and compile from source."
summary: ""
date: 2025-03-09T00:00:00Z
draft: false
weight: 999
toc: true
params:
  seo:
    title: ""
    description: ""
    canonical: ""
    robots: ""
  section:
    title: "Documentation"
    iconName: "book"
    startUrl: "/docs/features/"
---

Sqyre is a desktop macro builder: each **macro** is an ordered **tree of actions** you edit in a Fyne window. This page explains the main screen, how actions are added and edited, and how branching actions behave when you run a macro.

For the tech stack overview, see [Features](/docs/features/). For compiling the app, see [Build](/docs/build/).

## Main window

- **Macro tabs** — Each open macro appears as a tab. Use **+** (new tab) to create a macro; the name in the toolbar is saved when you submit it.
- **Macro list** (toolbar button with the list icon) — Browse all saved macros, open one in a tab, or delete a macro (with confirmation).
- **Toolbar (top row)** — Unselect, move selection up/down in the list, copy and paste the selected action, **play** the current macro, macro name field, and macro picker.
- **Toolbar (bottom row)** — **Global delay** (milliseconds) applied between Robotgo mouse/keyboard operations, live **mouse X/Y**, **hotkey** display, **trigger** (on press vs on release), and **record** for the hotkey chord.
- **Menu bar** — **Settings → Computer info** (screen and monitor sizes), **Data Editor** (points, search areas, items, programs, etc.), **User Settings**. Under **Macro**: **Add Action…** (picker dialog) and **Add Blank Action** (submenus by category).

When you press the macro hotkey or click play, execution runs with a log popup; the play button is disabled until the run finishes.

## Action tree

The center of each macro tab is a **tree** of actions.

- **Root** — Every macro’s tree is topped by a **Loop** named `root` (the macro’s top row). Your main steps are **children of that loop**. Its **iteration count** defaults to one; increase it to run the whole macro body multiple times. Tap the root row’s icon to edit it like any other loop.
- **Branches** — Actions that can contain child steps implement the same “container” behavior in the UI: **Loop**, **Image Search**, **OCR**, and **Find pixel**. They show expand/collapse like any tree branch; only these nodes can hold nested actions.
- **Leaves** — Actions with no children (for example **Click**, **Move**, **Key**, **Type**, **Wait**) appear as single rows.

Each row shows:

- **Type icon** (left) — Tap it to **open the action’s settings dialog**. Hover shows the action type name.
- **Summary** — A short description of parameters (coordinates, keys, targets, etc.).
- **Extra previews** — Image Search can show small target thumbnails; Find pixel may show a color swatch.
- **Remove** (right) — Deletes that action from its parent (not the same as copy/paste).

**Selection** — Click a row to select it. New actions are inserted relative to the selection (see below). Use the toolbar **unselect** control to clear selection.

**Reorder** — With a node selected, use **move up** / **move down** to swap it within its parent’s child list.

**Copy / paste** — **Copy** stores the selected action (including nested children for branch actions). **Paste** inserts a duplicate:

- If the selected node is a **branch**, the copy is appended as its **last child**.
- If the selected node is a **leaf**, the copy is inserted **below** it as the next sibling.
- With **no selection**, paste goes at the **end** of the root’s children.

## Adding actions

Use **Macro → Add Action…** for a four-column dialog (**Mouse & Keyboard**, **Detection**, **Variables**, **Miscellaneous**), or **Macro → Add Blank Action** for the same types via nested menus.

Insertion rules match the tree structure:

- If the **selected** node is a **branch**, the new action becomes a **new child** of that branch.
- If the **selected** node is a **leaf** (or you treat a non-container as the focus), the new action is added **next to** that node—as a sibling under the same parent.
- If **nothing** is selected, the new action is added under **root** (via the same parent logic using root as the effective context in code paths that resolve selection).

After adding, Sqyre usually opens the **action dialog** so you can configure the new step immediately.

## Editing actions

Tap the **left icon** on a row to edit that action. Saving updates the macro on disk and refreshes the tree row.

The **Data Editor** (Settings menu) is where you define shared resources—programs, items, **points**, **search areas**, masks, etc.—that many actions reference by name.

## How actions run (especially branches)

Execution starts at **root** and walks the tree according to each action type:

- **Loop** — Runs its **child actions in order**, then repeats for the configured **count**. The root loop also resets **Read from** (data list) iterators at the start of a macro run and drives the on-screen “macro active” indicator.
- **Image Search** — Searches for configured targets. For **each** match (in sorted order), it can set **output variables** (for example X/Y) and **item-related** built-ins (`StackMax`, `Cols`, `Rows`, `ItemName`, image dimensions when variants exist), then runs **child actions once per match**. After all matches, output X/Y are set back to the **first** match for anything that follows as a **sibling** after the Image Search node.
- **OCR** — Reads text from the search area. If the result **contains** the configured target string, **child actions run** (once). It can also write text and/or center coordinates to variables.
- **Find pixel** — Scans a rectangle for a color. If found, sets optional output X/Y and runs **children**; if not found, children are skipped and execution continues.

Leaf actions (clicks, keys, typing, waits, variables, **Run macro**, **Focus window**, etc.) run in sequence when reached. **Run macro** executes another saved macro’s root in the same way (with that macro’s own variable store).

Variable placeholders in fields (for example move coordinates) are resolved from the **current macro’s** variables when each step runs—so values produced by Image Search, OCR, Find pixel, **Set**, **Calculate**, or **Read from** can drive later steps.

## Open questions

If you use Sqyre and something here disagrees with the UI, [open an issue](https://github.com/sqyre-io/sqyre-io.github.io/issues) or PR on this docs site. Behavior is inferred from the [application source](https://github.com/luhrMan/sqyre); the authoritative labels are the live menus and dialogs.

---

Next: [Features](/docs/features/) · [Build](/docs/build/)
