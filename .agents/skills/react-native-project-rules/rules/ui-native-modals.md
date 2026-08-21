---
title: Reuse the Project's Modal and Sheet Components
impact: HIGH
impactDescription: consistent dismiss behavior, keyboard and safe-area handling already solved
tags: modals, bottom-sheet, react-navigation
---

## Reuse the Project's Modal and Sheet Components

This project already has `AppModalV2` and `BottomSheetModal` in `src/components/`. They carry the app's dismiss behavior, backdrop, keyboard handling, and bottom-inset handling. Reach for them before writing a modal or adding a sheet library.

Adding another sheet library is a dependency change and needs explicit user approval.

**Incorrect (new modal built from scratch, inset and back handling re-invented):**

```tsx
<Modal visible={visible} transparent>
  <View style={styles.backdrop}>
    <View style={styles.sheet}>{children}</View>
  </View>
</Modal>
```

**Correct:**

```tsx
import BottomSheetModal from 'components/modals/BottomSheetModal'

<BottomSheetModal visible={visible} onClose={close}>
  {children}
</BottomSheetModal>
```

Verify the actual props against the component rather than assuming this shape.

## When a native presentation is the better fit

For a screen-shaped modal that participates in navigation — a detail view, a filter screen, anything the back gesture should dismiss — use React Navigation v7's native presentation instead of a component-level modal:

```tsx
<Stack.Screen
  name="Filters"
  component={FiltersScreen}
  options={{ presentation: 'formSheet', sheetAllowedDetents: 'fitToContents' }}
/>
```

This gets swipe-to-dismiss, keyboard avoidance, and accessibility from the platform.

## Either way, check

- **Android hardware back** dismisses the modal. A sheet that ignores it traps the user.
- **Bottom inset** is preserved on anything anchored to the bottom of the sheet, including Android 3-button navigation. See `.ai/rules/code-style.md`.
- **Keyboard** does not double-count an inset the sheet already applies.
