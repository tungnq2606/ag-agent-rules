# Documentation Rules

Feature documentation in this project is onboarding documentation for engineers who are new to the project or unfamiliar with the feature.

Its purpose is to help a new engineer understand the feature, find the relevant code quickly, make normal changes safely, and avoid reverse-engineering the entire implementation.

## Explicit Request Only

NEVER create, update, regenerate, or reorganize feature documentation automatically after:

* development
* refactoring
* bug fixing
* verification
* plan completion
* architecture work
* handoff

Only create or update documentation when the user explicitly requests it.

An approved plan does NOT count as an explicit documentation request.

A request to document one feature authorizes documentation changes only for that feature.

Do not modify unrelated documentation or reorganize the documentation structure unless explicitly requested.

## Language

All feature onboarding documentation MUST be written in Vietnamese.

Use clear, natural Vietnamese suitable for software engineers.

Keep technical identifiers unchanged, including:

* source paths
* component names
* function names
* hooks
* types/interfaces
* API names
* route names
* state/store names
* library names

Do not translate identifiers from the codebase.

English technical terms may be kept when they are established project or industry terminology, but explanatory prose should be Vietnamese.

## Docusaurus

The project uses Docusaurus.

Before writing documentation:

1. inspect the existing documentation structure;
2. inspect nearby documentation pages;
3. inspect `docusaurus.config.*` or `sidebars.*` only when relevant;
4. follow the existing project conventions.

Preserve existing conventions for:

* location
* filename
* file extension
* front matter
* sidebar/category placement
* links
* components
* styling

Do not invent a new documentation hierarchy when an established one already exists.

## Format

Documentation should render as structured HTML through the existing Docusaurus system.

Preserve the current authoring format used by the project.

If the project uses Markdown or MDX:

* continue using `.md` or `.mdx`;
* use Docusaurus-compatible HTML/JSX when needed;
* reuse existing Docusaurus components where appropriate.

Do not create standalone `.html` files unless that is already an established project convention.

## Source of Truth

Documentation must describe the final system as it actually works.

Use this priority when information conflicts:

1. final implementation
2. tests and verified runtime behavior
3. API contracts and TypeScript types
4. accepted ADRs
5. approved plan
6. shared project memory
7. previous conversation

If implementation differs from the original plan, document the implementation.

Never present assumptions or unfinished behavior as verified facts.

## Onboarding Content

Include only sections relevant to the feature.

A good feature onboarding document should normally help a new engineer understand:

### Overview

* Feature dùng để làm gì?
* User sử dụng nó trong trường hợp nào?
* Hành vi chính nhìn từ phía user là gì?

### User Flow

Mô tả luồng chính của user qua feature, bao gồm các entry point và transition quan trọng.

### Mental Model

Giải thích các khái niệm chính mà engineer cần hiểu trước khi đọc code.

### Architecture

Giải thích các module chính và trách nhiệm của chúng.

Khi hữu ích, mô tả flow ở mức cao, ví dụ:

`Screen → Hook → State/Data Layer → Service → API`

Chỉ mô tả architecture thực sự tồn tại.

### Data and State Flow

Giải thích dữ liệu quan trọng đi qua feature như thế nào và state thuộc về đâu.

Phân biệt khi relevant:

* React Query → server state
* Redux → global/app-wide state
* Zustand → UI state
* component state → local state

### Key Entry Points

Liệt kê một số ít file hoặc directory quan trọng mà new member nên mở đầu tiên.

Với mỗi entry point, giải thích trách nhiệm của nó.

Không liệt kê toàn bộ file của feature.

### Common Change Guide

Khi hữu ích, chỉ ra nơi nên bắt đầu cho các thay đổi thường gặp, ví dụ:

* thay đổi API behavior
* thêm UI section
* thay đổi navigation
* thay đổi state
* thêm analytics

Đây là navigation guide, không phải step-by-step implementation tutorial.

### Platform Behavior

Chỉ ghi những behavior mobile-specific thực sự ảnh hưởng feature, ví dụ:

* Android/iOS differences
* safe area
* keyboard
* lifecycle
* permissions
* notifications
* deep links
* native integration

### Gotchas

Ghi lại những constraint hoặc behavior không hiển nhiên mà new member dễ hiểu sai và có thể gây bug.

Chỉ ghi gotcha đã được xác minh.

### Verification

Giải thích cách thường dùng để verify thay đổi của feature.

Follow `.ai/rules/verification.md`.

## Refactors

For documentation created after a refactor, describe primarily how the feature works today.

Do not turn onboarding documentation into a refactor history or changelog.

Mention previous architecture only when it is necessary to understand:

* a current constraint
* compatibility behavior
* deprecated behavior still in use
* an otherwise confusing architectural decision

Prefer linking to an ADR when historical architectural reasoning matters.

## Implementation References

Documentation should act as a map to the codebase, not a source-code dump.

Prefer a small number of meaningful paths with responsibility descriptions.

Do not:

* list every modified file;
* paste large source-code blocks;
* reproduce entire directory trees;
* duplicate API specifications;
* copy the implementation plan.

Reference existing source files, ADRs, API docs, and related feature docs instead.

## Updating Existing Documentation

If authoritative documentation for the feature already exists:

1. update that document;
2. preserve unrelated useful content;
3. remove information that is no longer true;
4. update affected links or diagrams.

Do not create duplicate authoritative documentation for the same feature.

## Completion Check

Before considering documentation complete, verify that:

* the user explicitly requested documentation;
* the document is written in Vietnamese;
* the requested scope was respected;
* existing Docusaurus conventions were preserved;
* the final implementation was inspected;
* the document reflects current verified behavior;
* important implementation paths are valid;
* a new engineer can identify where to start reading the code;
* a new engineer can understand the main architecture/data/state flow;
* important gotchas are documented;
* the engineer can understand how to verify a normal change.

Do not add detail merely to make the document longer.
