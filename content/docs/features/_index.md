---
title: "Features"
description: "Tech stack and action types for the Sqyre macro builder."
date: 2025-03-09
draft: false
weight: 10
toc: true
aliases:
  - /features/
params:
  seo:
    title: ""
    description: ""
---

Sqyre is built with a small set of libraries and exposes them through a **tree-based macro editor**. For **how to use the window** (toolbar, add/edit rules, copy/paste, execution), see the [Docs](/docs/) landing page.

## Tech stack

- **Fyne** — Cross-platform GUI
- **Robotgo** — Mouse and keyboard automation
- **Gosseract (Tesseract)** — OCR
- **GoCV (OpenCV)** — Computer vision (image search pipeline)

## Action types (current app)

Actions are grouped in the UI like this:

### Mouse & keyboard

- **Mouse Move** — Cursor to coordinates (optionally smooth); points and variables supported.
- **Click** — Mouse button click.
- **Key** — Hold or release a modifier/key.
- **Type** — Type text with optional per-key delay.

### Detection (branch actions)

These can contain **child actions** that run when the condition matches (see [Docs](/docs/) for execution details).

- **Image Search** — Find template images in a search area; optional wait-until-found; outputs and per-match child runs.
- **OCR** — Read text; run children when the read text contains a target string.
- **Find pixel** — Scan a region for a color; run children when a pixel matches.

### Variables

- **Set** — Assign a variable.
- **Calculate** — Evaluate an expression into a variable.
- **Read from** — Read a line from a data file (iterator resets each macro run at root).
- **Save to** — Write variable content to a file or the system clipboard.

### Miscellaneous

- **Wait** — Pause (milliseconds).
- **Focus window** — Bring a window to the front by title.
- **Run macro** — Run another saved macro’s root as a nested step.
- **Loop** — Repeat a sequence a fixed number of times (the macro **root** is also a loop).

Combine branches and leaves to automate workflows without writing code.
