---
name: document-feature
description: Create or update Vietnamese Docusaurus feature onboarding documentation only when the user explicitly requests documentation for a feature. Never invoke automatically after implementation, refactoring, verification, or plan completion.
---

# Document Feature

Use only when the user explicitly requests feature documentation.

Documentation is intended for onboarding engineers who are new to the project or unfamiliar with the feature.

Read:

`.ai/rules/documentation.md`

before writing.

## Workflow

1. Confirm the requested documentation scope.
2. Inspect the existing Docusaurus structure and nearby documentation.
3. Inspect `docusaurus.config.*` or `sidebars.*` only when relevant.
4. Determine the existing location, filename, extension, front matter, sidebar, and styling conventions.
5. Inspect the final implementation of the feature.
6. Inspect relevant tests, types, API contracts, ADRs, or completed plans only when needed.
7. Update an existing authoritative document when one already exists.
8. Otherwise create the document in the appropriate existing Docusaurus location.
9. Verify referenced paths, links, and implementation details before finishing.

## Language

All explanatory documentation MUST be written in Vietnamese.

Keep code identifiers unchanged, including:

- file paths
- component names
- functions
- hooks
- types/interfaces
- API names
- route names
- state/store names
- library names

Use established English technical terms when appropriate, but explanatory prose should remain Vietnamese.

## Content

Include only sections relevant to the feature.

A useful onboarding document should normally explain:

- Tổng quan
- Luồng người dùng
- Mental model
- Kiến trúc
- Luồng dữ liệu và state
- Các entry point quan trọng
- Hướng dẫn tìm nơi cần sửa cho các thay đổi thường gặp
- API/service interactions khi relevant
- Navigation khi relevant
- Platform-specific behavior khi relevant
- Loading, error và empty states
- Gotchas
- Cách kiểm tra thay đổi
- Tài liệu hoặc ADR liên quan

Do not force every section into every document.

## Onboarding Focus

The document should help a new engineer answer:

- Feature này làm gì?
- User đi qua feature như thế nào?
- Code nên bắt đầu đọc từ đâu?
- Module nào chịu trách nhiệm gì?
- Data đi qua hệ thống như thế nào?
- State được quản lý ở đâu?
- Muốn sửa một behavior phổ biến thì nên bắt đầu ở đâu?
- Có constraint hoặc gotcha nào dễ gây bug?
- Thay đổi nên được verify như thế nào?

Documentation should act as a map to the codebase, not a source-code dump.

## Source of Truth

Prefer information in this order:

1. final implementation
2. tests and verified runtime behavior
3. API contracts and TypeScript types
4. accepted ADRs
5. completed/approved plan
6. shared memory
7. previous conversation

If the implementation differs from the plan, document the implementation.

Never present assumptions or unfinished behavior as verified facts.

## Docusaurus Rules

Follow the existing project convention.

If documentation uses Markdown or MDX:

- keep the established `.md` or `.mdx` format;
- use Docusaurus-compatible HTML/JSX when needed;
- reuse existing Docusaurus components where appropriate.

Do not create standalone `.html` files unless that is already an established project convention.

Do not reorganize documentation or sidebars unless required by the requested scope.

## Rules

- Never create documentation automatically.
- An approved implementation plan is not permission to write documentation.
- Do not modify unrelated documentation.
- Do not create duplicate authoritative pages.
- Do not copy the implementation plan into the document.
- Do not list every modified file.
- Do not paste large source-code blocks.
- Prefer a small number of meaningful implementation entry points.
- Describe how the feature works today, not its refactor history.
- Link to ADRs when historical architecture reasoning matters.
- Keep the document detailed enough for onboarding but concise enough to maintain.

## Completion

Before finishing, verify that:

- the user explicitly requested the documentation;
- the document is written in Vietnamese;
- existing Docusaurus conventions were preserved;
- the final implementation was inspected;
- referenced paths and links are valid;
- the document reflects current verified behavior;
- a new engineer can understand the feature and know where to start making a normal change.