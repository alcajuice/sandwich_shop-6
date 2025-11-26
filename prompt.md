**PROMPT 1**

I have a sandwich shop app written in Flutter. I need your help writing good prompt I can send to an LLM to help me implement a new feature.

I have two pages: an order screen where users can select sandwiches and add them to their cart, and a cart screen where users can see the items in their cart and the total price.

I want to let the users modify the items in their cart. There are different ways a user might want to modify their cart like changing quantity or removing items entirely.

For each of these features, include a clear description and what should happen when the user performs an action. Output the result in a Markdown code block.

The app currently has these models:

Sandwich (with type, size, bread type)
Cart (with add/remove/clear methods and total price calculation)
It also has one repository:
Pricing (calculates prices based on quantity and size; the price of a sandwich has nothing to do with its type or bread)

Prompt for LLM: Implement "Modify Cart" features for Sandwich Shop Flutter app

Context:
- Flutter app with two screens: OrderScreen (select sandwiches, add to cart) and CartScreen (view items and total).
- Models:
  - Sandwich (type, size, breadType)
  - Cart (add/remove/clear methods, calculates total)
- Repository:
  - Pricing (calculates price by quantity and size; price independent of sandwich type/bread)
- Current constraint: OrderScreen passes maxQuantity (e.g., 5). Cart must respect this.

Goal:
Add UI and logic so users can modify items already in the cart. Implement the behaviors below, update the Cart API if needed, recalc totals via Pricing, and add tests.

Features (for each: description, what happens when action is performed, validation, UI suggestions, acceptance criteria):

1) Increment / Decrement Quantity (stepper)
- Description: Provide +/- controls (or Stepper) beside each cart item to change its quantity by 1.
- Action -> Result:
  - +: increase quantity by 1 up to maxQuantity. If attempt beyond max -> show inline validation ("Max X per order") and disable +.
  - -: decrease quantity by 1. If new quantity becomes 0 -> prompt or auto-remove depending on preference (see Remove behavior).
  - After change: update Cart model (new quantity), recalc item price via Pricing, update cart total, update UI immediately.
- Validation: quantity ∈ [1, maxQuantity]. If external change to maxQuantity, clamp existing quantities and notify user.
- UI: small vertical stepper or segmented +/– buttons next to quantity with disabled state.
- Acceptance: quantity updates reflect in Cart model and UI, totals change accordingly, buttons disable at bounds.

2) Set Quantity Directly (input)
- Description: Allow tapping quantity to open a numeric input dialog or inline editable field to set specific quantity.
- Action -> Result:
  - User enters integer. If <=0 -> treat as removal (show confirm). If > maxQuantity -> show error and offer to set to max.
  - On valid entry: update Cart and Pricing, refresh totals.
- Validation/UI: numeric keyboard, enforce integer input, show helpful validation messages.
- Acceptance: direct edits update cart and totals; invalid input shows clear error.

3) Remove Item
- Description: Remove an item from the cart.
- Action -> Result:
  - UI options: a "Remove" button, swipe-to-delete on list item, or trash icon.
  - On remove: remove item from Cart, recalc totals, show Snackbar with "Undo" option (re-add previous item and quantity).
  - If item removal affects any aggregated discounts or bundles, recalc accordingly (if applicable).
- Validation: ask for confirmation only for large orders or if removal is destructive; by default use Snackbar undo.
- Acceptance: item disappears, totals update, undo restores item and totals.

4) Edit Item (change sandwich options)
- Description: Allow editing sandwich options (size, bread, type) of an item already in cart.
- Action -> Result:
  - Open an "Edit Item" sheet/screen prefilled with the item's options using the same controls as OrderScreen.
  - On save: if edited item matches an existing cart entry (same options), merge quantities (clamp to maxQuantity) and remove duplicates; otherwise update the item in place.
  - Recalculate price using Pricing (price only depends on size and quantity).
- Validation: merging must not exceed maxQuantity; if merge would exceed, set to max and prompt user.
- Acceptance: editing updates the item or merges as expected; totals update.

5) Undo / Confirmation UX
- Description: Provide a consistent way to undo destructive actions.
- Action -> Result:
  - After remove or quantity change that results in deletion, show Snackbar "Item removed — Undo" for 3–5s.
  - If Undo tapped: restore previous state exactly (quantity, sandwich options).
- Acceptance: Undo reliably restores cart state.

6) Edge cases & validation rules
- If Pricing logic changes (e.g., size price changes) ensure Cart recalculates item and total prices immediately on quantity/size change.
- If cart contains many duplicate items, UI should group identical sandwich options into a single line item with combined quantity.
- If maxQuantity is updated at runtime, clamp cart quantities and notify user of changes with a non-blocking message.

Suggested API changes / methods to implement on Cart:
- updateItemQuantity(cartItemId, int quantity) -> returns updated item or error
- removeItem(cartItemId) -> returns removed item (for undo)
- editItem(cartItemId, Sandwich newSandwich) -> returns merged boolean and final item
- getCartItems() / stream or ChangeNotifier to notify UI about changes
- Optional: add undo buffer to Cart or coordinator

Implementation tasks for the developer LLM:
1. Data layer
   - Add updateItemQuantity, editItem, optional mergeDuplicates to Cart model.
   - Ensure Cart notifies listeners (ChangeNotifier or Streams) after changes.
   - Use Pricing to recalc single item price and Cart total.

2. UI
   - CartScreen list rows: show sandwich summary, quantity control (stepper +/–), per-item price, remove icon.
   - Implement tap-to-edit that opens existing OrderScreen item editor state as a modal.
   - Add swipe-to-delete with Snackbar undo.
   - Disable + when quantity == maxQuantity; disable – when quantity == 1 if you want to require explicit remove.

3. UX/Validation
   - Numeric input dialog for set-quantity with validation messages.
   - Show inline errors for attempts to exceed maxQuantity.
   - Snackbar undo for removes.

4. Tests
   - Unit tests for Cart methods: update quantity, remove, edit and merge behavior, total recalculation.
   - Widget tests for CartScreen interactions: increment/decrement, swipe delete + undo, edit flow.

Acceptance criteria (concrete)
- Changing quantity via stepper updates Cart model and total immediately.
- Directly setting quantity performs validation and updates total.
- Removing an item removes it from Cart and shows undo Snackbar that restores it.
- Editing an item updates the item or merges with existing identical item, totals update, and quantity does not exceed maxQuantity.
- All changes persist in the Cart object and are observable by UI.

Example user flows to implement as tests:
- Add 1 Ham-Medium-White, then increment to 3, total increases accordingly.
- Add duplicate Ham-Medium-White (quantity 2), Cart merges into single line with quantity 3.
- Decrement quantity to 0 -> item removed and Snackbar appears; Undo restores it.
- Edit a Tuna-Large-Wheat to change size to Medium; price updates via Pricing and cart total updates.

Deliverable checklist for LLM:
- Provide code patches for Cart model (new methods) and CartScreen UI updates.
- Provide unit tests for Cart behavior.
- Ensure Pricing is used when recalculating prices.
- Keep maxQuantity enforced everywhere; surface validation messages.

Keep message brief and ask follow-ups if you need the Cart/CartItem class source, current CartScreen code, or the Pricing API signatures to produce exact code patches.


**PROMPT 2**
Write a detailed requirements document for the feature described in my previous prompt. The requirements should include:

A clear description of the feature and its purpose.
User stories that describe how different users will interact with the feature.
Acceptance criteria that define when the feature is considered complete.
Respond in a structured Markdown format with separate subtasks.

**Modify Cart Feature — Requirements Document**

**Overview**
- **Purpose:** Add robust cart-modification capabilities to the Sandwich Shop Flutter app so users can change quantities, remove items, and edit sandwich options directly from the `CartScreen`. Changes must update prices using the existing `Pricing` repository and respect the existing `maxQuantity` constraint passed from `OrderScreen` (e.g., `maxQuantity: 5`).
- **Scope:** UI and business-logic changes to `Cart`, `CartScreen`, and related components. Include API additions to the `Cart` model (update quantity, edit item, remove/undo), UI controls (stepper, numeric input, edit modal, swipe-to-delete), and unit/widget tests.
- **Out of scope:** Persisting cart to remote storage, complex promotional rules not currently implemented, or changing `Pricing` algorithm beyond using it for recalculation.

**Subtasks**
- Subtask 1 — Draft: Requirements Document
  - Goal: Produce this detailed requirements doc.
  - Deliverable: This Markdown file.

- Subtask 2 — Data Model & API
  - Goal: Extend `Cart` model with explicit methods for modifying items and notifying UI.
  - Deliverables:
    - `updateItemQuantity(cartItemId, int quantity)` -> updates quantity or returns an error if invalid.
    - `removeItem(cartItemId)` -> returns removed item (for undo).
    - `editItem(cartItemId, Sandwich newSandwich)` -> modifies item and returns merge status.
    - `stream` or `ChangeNotifier` support for UI updates.

- Subtask 3 — UI (CartScreen)
  - Goal: Add controls on each cart row for modification.
  - Deliverables:
    - Stepper / + and − buttons for quantity.
    - Tap-to-edit to open item editor prefilled with sandwich options.
    - Numeric entry dialog to set exact quantity.
    - Swipe-to-delete / remove button with Snackbar Undo.
    - Per-item price and recalculated total.

- Subtask 4 — UX & Validation
  - Goal: Ensure clear error messages and consistent undo behavior.
  - Deliverables:
    - Inline validation for exceeding `maxQuantity`.
    - Snackbar undo on removes and destructive changes.
    - Merge conflict messaging if editing causes merge/clamping.

- Subtask 5 — Tests
  - Goal: Add unit and widget tests validating business rules and UI flows.
  - Deliverables:
    - Unit tests for `Cart` methods.
    - Widget tests for `CartScreen` interactions (increment, decrement, numeric input, swipe delete + undo, edit merge).

- Subtask 6 — Review & QA
  - Goal: Review implementation, run tests, and verify acceptance criteria.
  - Deliverable: Sign-off that acceptance criteria are satisfied.

**User Stories**

- **Story 1 — Casual Shopper (Single-item changes)**
  - As a casual shopper,
  - I want to increase or decrease the quantity of an item in my cart using +/− controls,
  - So I can buy the right number of sandwiches without leaving the cart.
  - Notes: + is disabled at `maxQuantity`, − stops at 1 or prompts for removal if reaching 0 based on UX decision below.

- **Story 2 — Power Shopper (Direct quantity set)**
  - As a power shopper,
  - I want to tap the quantity and enter a specific number (numeric input or dialog),
  - So I can quickly set the desired quantity (e.g., 4) without tapping + repeatedly.

- **Story 3 — Removing Items**
  - As any shopper,
  - I want to remove an item from my cart (via swipe-to-delete or trash icon),
  - So I can correct mistakes quickly.
  - The app should show an undo Snackbar so I can restore the item if I removed it accidentally.

- **Story 4 — Editing Item Options**
  - As a shopper,
  - I want to edit a sandwich already in the cart (change size, bread, or type),
  - So I can customize my order after adding items without starting over.
  - If editing results in an item identical to another entry, merge them and clamp to `maxQuantity`.

- **Story 5 — Guest or Changing Max Quantity**
  - As a user whose `maxQuantity` policy changed (e.g., from 8 to 5),
  - I want the cart to clamp quantities that exceed the new max and notify me about changes,
  - So quantities remain valid and I’m aware of adjustments.

- **Story 6 — Undo & Safety**
  - As any user,
  - I want an immediate way to undo destructive actions (remove or quantity change that deletes an item),
  - So I can recover from mistakes (undo in Snackbar).

**Detailed Acceptance Criteria**

General:
- The `Cart` model exposes methods: `updateItemQuantity`, `removeItem`, `editItem`, and notifies listeners (via `ChangeNotifier`, `ValueNotifier`, or stream).
- All UI updates are driven by the `Cart` notification API (no UI-local-only state for cart totals).
- All price calculations use the `Pricing` repository; item and total prices update immediately after changes.

Increment / Decrement (Stepper)
- UI: Each cart row shows a quantity control with + and −.
- Behavior:
  - Pressing + increases quantity by 1 until `maxQuantity`.
  - Pressing − decreases quantity by 1 until 1. If user decrements from 1 and UX chooses removal-on-zero, a confirmation or automatic remove + Undo appears.
  - + button is disabled when quantity == `maxQuantity`.
  - − button is disabled only if you choose to prevent decrementing to zero without explicit Remove; otherwise allow decrement to 0 to trigger removal flow.
- Verification:
  - After increment/decrement, the `Cart` contains updated quantity, per-item price recalculated by `Pricing`, and cart total updated in UI.

Set Quantity Directly
- UI: Tapping quantity opens a numeric input dialog with numeric keyboard.
- Validation:
  - Non-integer or negative inputs are rejected with inline error.
  - Inputs > `maxQuantity` show an error and suggest setting to `maxQuantity`.
  - Input ≤ 0 triggers removal confirmation or removal + Undo.
- Verification:
  - Valid input updates the cart, recalculates prices, closes dialog, and shows new totals.

Remove Item
- UI: Swipe left/right to delete or press a trash icon.
- Behavior:
  - Removing an item deletes it from `Cart`, updates totals, and shows a Snackbar with an Undo button visible for 3–5 seconds.
  - If Undo is tapped, the item and its previous quantity are restored exactly and totals revert.
- Verification:
  - Removed items are absent from `Cart` and UI until Undo is tapped.
  - Undo restores original item data and totals.

Edit Item (change options)
- UI: An Edit action opens a sheet/modal prefilled with the item’s options using the same UI as `OrderScreen`.
- Behavior:
  - On Save, if the edited configuration matches another existing cart item, combine quantities and clamp to `maxQuantity`. If clamping is required, inform the user via a short message (Snackbar or inline).
  - Price recalculation uses `Pricing` (size+quantity -> price).
  - If the edited configuration differs, update the item in place.
- Verification:
  - Edited item reflects new options and price; totals update.
  - Merges occur when items are identical; final quantity ≤ `maxQuantity`.

Undo / Confirmation UX
- After remove or deletion via quantity change, a Snackbar presents "Undo".
- Undo restores exact prior state including sandwich options and quantity.
- No destructive permanent deletion until the undo window expires.

Merging & Grouping Duplicates
- Cart groups identical sandwich configurations into a single line item with combined quantity.
- When merging, combined quantity is clamped to `maxQuantity` and clamped amount is reported to the user.

Edge Cases & Validation
- If `maxQuantity` changes at runtime:
  - Quantities above the new `maxQuantity` are clamped immediately.
  - A non-blocking notification explains which items were reduced.
- If `Pricing` changes (e.g., size-based price update), all item prices and totals are recalculated immediately.
- Inputs are protected against integer overflow and invalid types.

Performance & Non-functional
- UI updates must be responsive (<=100ms perceived for updates).
- Accessibility: controls must be accessible (semantics labels on +/−, remove, and edit actions).
- Localization: text messages and validation strings should use existing localization approach.

Tests (Minimum required)
- Unit tests for:
  - `updateItemQuantity` normal and boundary cases.
  - `removeItem` returns removed payload and supports undo.
  - `editItem` performs update and merges correctly.
  - Price recalculation integrates with `Pricing`.
- Widget tests for:
  - Increment, decrement flow updates UI and `Cart`.
  - Direct numeric entry validation and update.
  - Swipe-to-delete + Snackbar Undo restores state.
  - Editing item leading to merge/clamp behaviors.

Out of scope / Assumptions
- Assumes `Sandwich` equality semantics (type, size, bread) are well-defined for merging.
- Assumes `Pricing` API is available and synchronous or returns quickly enough for immediate UI update.
- Persisting cart state beyond in-memory/session is out of scope.

**Acceptance Checklist (must be satisfied to close feature)**
- [ ] `Cart` API extended with `updateItemQuantity`, `removeItem`, `editItem`, and exposes change notifications.
- [ ] `CartScreen` shows +/− stepper, numeric input, edit and remove affordances for each line item.
- [ ] Quantity updates recalc per-item price and total using `Pricing` and reflect immediately in UI.
- [ ] Removing an item presents Snackbar Undo that fully restores item state.
- [ ] Editing an item updates or merges entries and clamps to `maxQuantity` with appropriate user feedback.
- [ ] All edge cases from "Edge Cases & Validation" are handled and have unit tests.
- [ ] Widget tests exist for main interaction flows and pass.
- [ ] UX elements are accessible and localizable.

**Next Steps**
- Implement Data Model & API changes in `lib/models/cart.dart` (or equivalent).
- Implement UI changes in `lib/views/cart_screen.dart`.
- Add unit tests in `test/repositories` and widget tests in `test/views`.
- Run test suite and address any failures, then demo the flows.

**PROMPT 3: About Screen & "about us" link**

User: "In the program, how do we access the about screen"

Assistant:
- Use the named route: `Navigator.pushNamed(context, '/about');`
- Or push directly: `Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen()));`
- `lib/main.dart` already registers `'/about'` in `routes` so the named route is available.

User: "I would like there to be text under the logo int the top left that says 'about us'. This should be similar to a hyperlink that would take us to the about_screen page"

Assistant:
- I will add a small under-logo, underlined blue `Text` that navigates to `'/about'` when tapped. Implemented via `GestureDetector(onTap: () => Navigator.pushNamed(context, '/about'))` wrapping the `Text('about us')`.
- I applied the change to `lib/views/cart_screen.dart`.

User: "could you add it to all the screens, since the logo is visible on every screen"

Assistant:
- I searched for `Image.asset('assets/images/logo.png')` and updated each file that contains it (`cart_screen.dart` and `order_screen.dart`) to include the under-logo link.
- For each screen I added the same underlined blue `Text('about us')` with `GestureDetector` to navigate to `'/about'`.

User: "the text is overflowed by 70 pixels. Instead, could you place the about us button in the top middle of the page"

Assistant:
- I moved the `about us` link from the `leading` area to the centered `AppBar` title on both `CartScreen` and `OrderScreen`.
- The `title` is now a `Column` that renders the screen title and the small underlined `about us` link below it; `centerTitle: true` keeps it in the top middle and avoids overflow.

Notes:
- The `about us` link uses the named route `'/about'` defined in `lib/main.dart`.
- Optionally, `InkWell` can be used (wrapped in `Material`) for a ripple effect instead of `GestureDetector`.

