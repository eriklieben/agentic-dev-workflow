# User Personas & Scenario Tasks

Each tester receives a **persona** (who they are) and a **scenario** (a realistic task to accomplish). This mirrors real UX testing: testers don't just visit pages, they try to complete goals as real users would.

## Persona Sources

Personas come from one of three sources (see SKILL.md Phase 2.2):

1. **`ux-study.json`** in the project root (explicit, project-specific)
2. **Generated from documentation** (PRDs, README, design docs)
3. **Asked from the user** (interactive)

## Persona Structure

Each persona must have:

- **Name**: A short archetype label (e.g., "The Newcomer", "The Power User")
- **Background**: Who this person is and why they're here (1-2 sentences)
- **Scenario**: What they're trying to accomplish in this session (1 sentence)
- **Tasks**: 4-6 concrete actions they would realistically attempt

The key principle: each persona has a **motivation**, a **goal**, and **concrete tasks** that test the application from their unique perspective.

## Generating Personas from Documentation

When generating personas from project docs, follow this pattern:

1. Identify the application's **primary user types** (e.g., new user, returning user, admin, content creator, viewer)
2. For each user type, define a realistic scenario based on the application's features
3. Create 4-6 tasks per persona that exercise different areas of the application
4. Ensure personas cover a mix of: first-time experience, regular usage, edge cases, and administrative tasks
5. Generate 5-10 personas depending on the application's complexity

### Example Persona (for an e-commerce site)

```markdown
## Persona 0 — "The Bargain Hunter"
**Background**: You're looking for the best deal. You compare prices and read reviews before buying.
**Scenario**: "Find a specific product, compare options, and complete a purchase."
**Tasks**:
1. Search for a product by name
2. Filter results by price range
3. Read reviews on 2-3 products
4. Add the best option to your cart
5. Go through checkout (stop before payment)
6. Check if your cart persists after navigating away
```

### Example Persona (for a SaaS dashboard)

```markdown
## Persona 0 — "The New Employee"
**Background**: You just joined the company and need to set up your workspace. You've never used this tool.
**Scenario**: "Complete onboarding, explore the dashboard, and set up your first project."
**Tasks**:
1. Complete the onboarding wizard
2. Explore the main dashboard — is it clear what to do first?
3. Create a new project with a name and description
4. Invite a team member
5. Check notification settings
6. Find the help documentation
```

## Persona Assignment

Assign persona `i % NUM_PERSONAS` to agent `i`. When N exceeds the number of defined personas, agents cycle through them, which is valuable for cross-checking the same persona in different theme/viewport combos.

For large runs (N > number of defined personas), generate additional personas on the fly following the same structure.

---

## Accessibility Personas

Accessibility testers use the same think-aloud protocol but approach the application through the lens of their specific disability. They focus on **barriers**: things that prevent or significantly impair their ability to use the application. Assign accessibility persona `j % 5` to accessibility tester index `j`.

Each accessibility tester's prompt should include the same setup/login steps as regular testers, **plus** their disability-specific instructions below. Their reports should use the same format as regular tester reports, with an added `## Accessibility Barriers` section.

### A11y Persona 0 — "Screen Reader User" (Blind)
**Disability**: Completely blind. Uses a screen reader (NVDA/JAWS/VoiceOver) to navigate the web. Cannot see any visual content.
**Scenario**: "You rely entirely on screen reader output. Navigate the application using only keyboard and check if the screen reader experience makes sense."
**Testing focus**:
1. After each page loads, run `playwright-cli snapshot` and examine the **accessibility tree**. Check: Are headings hierarchical (h1 → h2 → h3)? Do images have alt text? Are interactive elements labeled?
2. Check tab order: Does focus move in a logical order? Can you tell where focus is?
3. Check for ARIA landmarks: Does the page have `<nav>`, `<main>`, `<aside>`, `<header>`, `<footer>` or equivalent `role` attributes?
4. Check forms: Are inputs associated with labels? Do error messages get announced?
5. Check dynamic content: After actions, is there a live region or status announcement?
6. Check any map/chart/visual components: Is there a text alternative?
**Report extra section**: `## Accessibility Barriers` listing each barrier with the WCAG criterion it violates.

### A11y Persona 1 — "Keyboard-Only User" (Motor Impairment)
**Disability**: Cannot use a mouse due to motor impairment. Navigates entirely with keyboard (Tab, Enter, Space, Arrow keys, Escape).
**Scenario**: "You can only use your keyboard. Try to complete all tasks without touching the mouse."
**Testing focus**:
1. Can you reach every interactive element by pressing Tab? Are there any keyboard traps?
2. Is there a visible focus indicator on every focusable element?
3. Can you open and close modals/dropdowns with Escape?
4. Can you activate buttons with Enter and Space?
5. Can you navigate the mobile menu (if applicable) with keyboard?
6. Skip links: Is there a "Skip to main content" link at the top?
**Report extra section**: `## Accessibility Barriers` listing keyboard navigation issues.

### A11y Persona 2 — "Low Vision User" (Partial Sight)
**Disability**: Severe low vision. Uses browser zoom at 200-400% and may use high-contrast mode.
**Scenario**: "You need to zoom in significantly and rely on high contrast to read content."
**Testing focus**:
1. Set browser zoom to 200%. Does the layout still work? Is anything cut off or overlapping?
2. Test at 400% zoom. Can you still navigate? Does content reflow or require horizontal scrolling?
3. Check text contrast: Are there areas where text is hard to distinguish from the background?
4. Check that information isn't conveyed by color alone
5. Check icon-only buttons: Can you tell what they do without hovering?
6. Check data visualizations at high zoom levels
**Report extra section**: `## Accessibility Barriers` listing visibility and zoom issues.

### A11y Persona 3 — "Cognitive Disability User"
**Disability**: Has difficulty processing complex information, remembering steps, and reading long text.
**Scenario**: "Complex interfaces overwhelm you. You need things to be simple, predictable, and clearly labeled."
**Testing focus**:
1. Is the navigation consistent across pages?
2. Are labels and button text clear and descriptive?
3. Are error messages helpful? Do they explain what went wrong and how to fix it?
4. Is there too much information on any page?
5. Are multi-step processes broken into clear steps with progress indicators?
6. Can you recover from mistakes?
**Report extra section**: `## Accessibility Barriers` listing complexity and comprehension issues.

### A11y Persona 4 — "Deaf/Hard of Hearing User"
**Disability**: Profoundly deaf. Cannot hear audio content. Relies on visual information and captions.
**Scenario**: "You cannot hear anything. Check if the application relies on audio for any information or feedback."
**Testing focus**:
1. Are there any audio-only notifications or alerts?
2. Do video content links indicate if captions/subtitles are available?
3. Are notification/alert banners purely visual?
4. Check for any time-based audio content that lacks transcripts
5. Check if form validation uses only visual indicators
6. Are live/real-time features accessible without audio?
**Report extra section**: `## Accessibility Barriers` listing audio-dependency issues.

---

## Technical Test Checklist (all personas)

In addition to the scenario tasks, every tester should verify these on each page they visit:

**Theme checks** (report issues specific to your assigned theme):
- Text is readable against the background
- Interactive elements (buttons, links) are clearly visible
- Form inputs have proper borders/contrast
- Maps, charts, and images adapt to the theme
- No "flash" of wrong theme on page load

**Viewport checks** (report issues specific to your assigned viewport):
- Content fits within the viewport (no horizontal scroll)
- Touch targets are at least 44x44px (mobile)
- Text is readable without zooming
- Navigation is accessible (hamburger menu on mobile, full nav on desktop)
- Modal dialogs fit the screen
