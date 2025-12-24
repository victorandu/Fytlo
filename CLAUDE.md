# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Fytlo is a SwiftUI iOS application for AI-powered virtual clothing try-on.

Users:
1. Upload a full-body photo
2. Select garments (top/bottom)
3. Generate a realistic try-on preview

This repo contains frontend UI + state logic only. Backend exists separately and is not yet integrated.

## Build & Run

```bash
# Build from command line
xcodebuild -project Fytlo/fytloapp.xcodeproj -scheme fytloapp -sdk iphonesimulator build

# Run tests
xcodebuild -project Fytlo/fytloapp.xcodeproj -scheme fytloapp -sdk iphonesimulator test
```

## Core Principles (NON-NEGOTIABLE)

1. **Apple-native only**
   - Swift / SwiftUI
   - Combine for reactivity
   - No third-party dependencies
   - No design libraries

2. **MVVM is enforced**
   - Views are dumb
   - ViewModels own logic and state
   - No business logic in Views

3. **Design-system first**
   - No hardcoded colors, fonts, spacing, blur, or materials inside screens
   - All styling goes through the DesignSystem layer

4. **iOS 26 "Liquid Glass"**
   - Use system materials via a centralized abstraction
   - Provide fallback for earlier iOS
   - Never stack multiple glass layers
   - Readability > aesthetics

## Architecture Rules

**Allowed:**
- SwiftUI
- Combine
- NavigationStack
- @State / @StateObject / @Observable
- @AppStorage (for onboarding flags only)

**Forbidden:**
- Redux-style global state
- Third-party UI frameworks
- Custom blur hacks scattered in views
- Heavy animations
- Rewriting AppViewModel without explicit instruction

## Folder Responsibilities

```
FytloAppUI/
├── App entry point
├── AppRouter
└── Navigation setup only

ViewModels/
├── AppViewModel is the single source of truth
├── No UI code
└── No styling

Views/
├── Screen composition only
├── Use DesignSystem components
└── No hardcoded visual styles

DesignSystem/ (CRITICAL)
├── Glass/
│   ├── GlassSurface.swift        # Liquid Glass abstraction
│   ├── ScrimOverlay.swift        # Text readability over images
│   └── GlassModifier.swift
├── Tokens/
│   ├── Colors.swift
│   ├── Typography.swift
│   └── Spacing.swift
└── Components/
    ├── FytloButton.swift
    ├── TopBar.swift
    ├── BottomActionBar.swift
    ├── StateViews.swift
    └── Cards.swift
```

**No View may directly use Material, blur, or opacity outside DesignSystem folder.**

## Liquid Glass Rules (iOS 26)

- Prefer system-provided materials / controls
- Centralize `#available(iOS 26, *)` logic
- One glass surface per layer
- Text over images must use ScrimOverlay or subtle GlassSurface container

## Core Business Logic (in AppViewModel)

1. **Full-body requirement**: Body photo must pass validation (height ≥ 900px, aspect ratio ≥ 1.2)
2. **One swap per generation**: User can only change ONE garment slot (top OR bottom) per generation attempt. `dirtySlot` tracks which slot is "dirty" and locks the other.
3. **Generation gating**: `canGenerate` enforces: not already generating, body exists, dirty slot has an image

## Screen Expectations

Each screen must:
- Compile
- Handle loading / error / empty / success (even if mocked)
- Use DesignSystem components
- Avoid inline styling

Current screens: WelcomeView, BodyUploadView, OutfitBuilderView, GeneratingView

## What Claude SHOULD Do

- Implement DesignSystem components
- Refactor existing views to use the system
- Clean up layout issues
- Fix compiler or preview errors
- Add SwiftUI previews
- Keep code modular and readable

## What Claude MUST NOT Do

- Redesign user flow
- Change AppViewModel logic
- Add backend calls unless explicitly requested
- Introduce new architectural patterns
- Add animations without approval
- Change visual direction without instruction

## Definition of Done

A task is complete only if:
- App builds successfully
- SwiftUI previews compile
- No hardcoded styles in screens
- Changes are isolated and reversible
- Diff summary is provided

## Required Output Format

When finishing a task, always provide:
1. Summary of changes
2. Files added / modified
3. Build result
4. Screens affected
5. Notes / risks (if any)

## Backend Integration (Planned)

See `fytlo_spec.json` for planned API:
- `POST /v1/upload-body` - Upload body photo, get sessionId
- `POST /v1/upload-garment` - Upload garment, get garmentId
- `POST /v1/try-on` - Initiate generation with changedSlot
- `GET /v1/try-on/{attemptId}` - Poll status

## Guiding Rule

**If you are unsure, do nothing and ask. Do not guess design or product intent.**
