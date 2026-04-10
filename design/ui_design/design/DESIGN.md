# Design System Documentation: The Glacial Sanctuary

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Glacial Sanctuary."** 

This is not a standard utility app; it is an editorial experience that evokes the stillness of a Nordic winter and the security of a modern, firelit cabin. We achieve this by rejecting the "boxed-in" nature of traditional web grids. Instead, we embrace intentional asymmetry, generous negative space (reminiscent of an untouched snowfield), and sophisticated layering. 

The goal is to make the user feel **calm and private**. We avoid visual noise. Elements should appear to float or emerge from a mist rather than being "pasted" onto a page. By utilizing extreme typographic scale and tonal depth, we create a digital environment that feels intelligent, premium, and inherently trustworthy.

---

## 2. Colors & Surface Philosophy
The palette is a sophisticated blend of high-contrast "Deep Pine" accents and low-contrast "Frost" transitions.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to define sections or containers. 
Structure must be achieved through:
- **Tonal Shifts:** Placing a `surface-container-low` card against a `surface` background.
- **Negative Space:** Using the Spacing Scale to imply boundaries.
- **Glassmorphism:** Using depth to separate layers.

### Surface Hierarchy & Nesting
Treat the UI as physical layers of frosted glass and compacted snow.
- **Foundation:** `surface` (#f5fafc) is the base of the "landscape."
- **Nesting:** Use `surface-container-lowest` (#ffffff) for high-priority floating cards to create a "brightest-white" highlight. Use `surface-container-high` (#e4e9eb) for recessed elements like input fields or secondary sidebars.
- **The "Glass & Gradient" Rule:** Floating action elements (Modals, Navigation Bars) must use **Glassmorphism**. Apply `surface-container-lowest` at 70% opacity with a `backdrop-blur` of 20px–40px.
- **Signature Transitions:** For primary CTAs, use a subtle linear gradient from `primary` (#00464a) to `primary-container` (#006064) at a 135-degree angle. This provides a "depth of pine" that flat color cannot replicate.

---

## 3. Typography
We utilize a dual-typeface system to balance "High-End Editorial" with "Modern Utility."

*   **Display & Headline (Manrope):** Chosen for its geometric yet warm personality. Headlines should use `headline-lg` or `display-sm` with a tight `letter-spacing` (-0.02em) to feel authoritative and architectural.
*   **Body & Labels (Inter):** The workhorse for "Trust and Intelligence." Use `body-lg` for standard reading. Increase `line-height` to 1.6x to maintain the "Scandinavian Minimalism" feel of breathing room.

**Hierarchy as Identity:**
- Use extreme scale contrast. A `display-lg` title should often sit near a `label-md` caption. This "High-Low" pairing is a hallmark of premium editorial design.
- **Kit the Fox Integration:** In empty states or headers, pair a `headline-sm` greeting with a subtle, low-opacity "Kit" mascot icon to soften the intelligent tone with a touch of "Cozy Cabin" warmth.

---

## 4. Elevation & Depth
Depth in this system is a measure of "Atmospheric Perspective," not shadow-heavy skeuomorphism.

### The Layering Principle
Achieve lift by stacking tokens. A `surface-container-lowest` element on top of a `surface-container-low` background creates a natural, soft separation. This mimics light hitting different depths of snow.

### Ambient Shadows
If a floating effect is required (e.g., a primary modal):
- **Color:** Use `on-surface` (#171c1e) at 4%–6% opacity.
- **Setting:** `Blur: 40px`, `Y-Offset: 12px`. 
- **Goal:** The shadow should be felt, not seen. It should look like an ambient occlusion glow rather than a drop shadow.

### The "Ghost Border" Fallback
If accessibility requirements (WCAG) demand a border, use a **Ghost Border**:
- **Token:** `outline-variant` (#bec8c9) at 15% opacity.
- **Instruction:** Never use a 100% opaque outline. It breaks the "Scandinavian" softness.

---

## 5. Components

### Buttons
- **Primary:** Roundedness `full`. Gradient from `primary` to `primary-container`. Typography `title-sm` (Inter, Medium).
- **Secondary (Glass):** `backdrop-blur` (12px) with a `surface-container-lowest` fill at 40% opacity.
- **Interaction:** On hover, increase the `backdrop-blur` or slightly shift the gradient brightness.

### Input Fields
- **Styling:** Use `surface-container-high` as the background. Roundedness `DEFAULT` (1rem/16px).
- **States:** For focus, do not use a heavy border. Use a 2px "Ghost Border" of `primary` at 40% opacity.

### Cards & Lists
- **Prohibition:** Divider lines are forbidden. 
- **Separation:** Use `1.5rem` to `2rem` of vertical white space to separate list items. For complex data, use alternating tonal backgrounds (`surface` vs `surface-container-low`).

### Navigation (The "Floating Frost")
- Bottom or Top navigation should be a floating "pill" using the Glassmorphism rule. It should not span the full width of the screen, allowing the "snow" (background) to wrap around it.

### Mascot Integration (Kit the Fox)
- **Subtle Presence:** "Kit" should appear as a "ghost" element (opacity 5-10%) in the background of cards, or as a small, minimal line-art icon in the `title-sm` section of onboarding screens.

---

## 6. Do's and Don'ts

### Do
- **Embrace Asymmetry:** Align text to the left but allow imagery or "Kit the Fox" to break the grid on the right.
- **Use Micro-Textures:** Apply a very faint "grain" or "snow texture" (opacity 2%) to `surface` layers to give a tactile, paper-like quality.
- **Prioritize Breathing Room:** If you think there is enough padding, add 8px more. Scandinavian design lives in the space between elements.

### Don't
- **Don't use hard black (#000000):** Use `on-surface` (#171c1e) for all text to keep the "Deep Pine" tonality.
- **Don't use sharp corners:** Every element must have at least `DEFAULT` (16px) roundedness to maintain the "Soft/Cozy" brand personality.
- **Don't use high-velocity animations:** Transitions should be slow and "drifting" (300ms–500ms) with ease-out curves, mimicking falling snow.