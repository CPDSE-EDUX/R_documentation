# Build Plan: Free AI Coding-Help Chatbot for a Quarto GitHub Pages Site

## Goal
Add a collapsible/popup AI chat widget to an existing Quarto-built website hosted on GitHub Pages. The widget helps beginners (mostly pharmacy students) with simple R coding questions. The whole system must be **completely free** — no API costs, no paid hosting, no credit card required.

## Hard constraints (do not violate)
- **$0 total cost.** No paid API keys, no paid tiers, no card-required signups.
- **GitHub Pages is static only.** It serves HTML/CSS/JS. It cannot run a backend, so the model must be hosted elsewhere and called from the browser.
- **HTTPS everywhere.** GitHub Pages is served over HTTPS, so the browser will block calls to any non-HTTPS (`http://`) backend (mixed-content error). The backend endpoint must be HTTPS.
- **Beginner-friendly output.** The assistant targets people new to coding. Answers should be short, patient, use simple language, and give small runnable R examples. It should explain *why*, not just hand over code.
- **Low/occasional traffic.** Built for a class of students asking occasional questions, not high concurrency.

## Architecture (two pieces)
1. **Backend** — a Hugging Face Space (free CPU tier) that hosts a small open-weight instruction model and exposes it as an HTTPS API endpoint.
2. **Frontend** — a floating chat widget (plain HTML/CSS/JS) injected site-wide into the Quarto site, which calls the backend endpoint.

Chosen backend: **Hugging Face Spaces**, because it is free, requires no server administration, and provides an HTTPS endpoint automatically. Accept its main tradeoff: free Spaces sleep after inactivity, so the first request after idle takes ~30–60s to "wake." This is acceptable for occasional student use, but the widget UI must handle it gracefully (see UX requirements).

---

## Part 1 — Backend: Hugging Face Space

### Setup
- Create a free Hugging Face account and a new **Space**.
- SDK: **Gradio** (gives a built-in HTTPS API endpoint and a simple way to run the model on the free CPU tier).
- Hardware: **free CPU basic tier** (no GPU, ~16GB RAM). Do not select any paid hardware.

### Model
- Use a small instruction-tuned coding model that runs on CPU within the free tier's memory, e.g. **`Qwen/Qwen2.5-Coder-1.5B-Instruct`** (good at basic R/Python, small enough for CPU).
- If it is too slow or too large in practice, fall back to an even smaller instruct model (e.g. a ~0.5B–1B instruct model). Keep the model swappable via a single variable.
- Load the model with the `transformers` library. Use the tokenizer's chat template to format messages.

### System prompt (bake this into every request)
The model must always be steered with a system prompt along these lines (reword as needed, keep the intent):
> You are a friendly tutor helping beginners — mostly pharmacy students — learn to code in R. Assume the user knows very little. Explain simply and patiently, avoid jargon (or define it when unavoidable), and keep answers short. When you show code, give small, complete, runnable R snippets and briefly explain what each part does and why. If a question is ambiguous, ask one short clarifying question. Prefer base R and common beginner packages. Do not overwhelm the user.

### API behavior
- Expose an endpoint that accepts the user's message (and ideally short conversation history) and returns the assistant's reply as text.
- Prepend the system prompt and format the full message list with the chat template before generation.
- Keep generation parameters modest (limited max new tokens, e.g. ~256–512) to keep CPU responses reasonably fast.
- **Enable CORS** so the browser on the GitHub Pages domain is allowed to call the Space. The response must permit the site's origin (either `*` or the specific GitHub Pages origin). This is essential — without it the browser blocks the call.
- Handle concurrent/duplicate requests safely; it's fine to keep it simple given low traffic.

### Files to produce for the Space
- `app.py` — loads the model + tokenizer, defines the system prompt, defines a chat function, exposes it via Gradio with the API enabled and CORS allowed.
- `requirements.txt` — pin the needed libraries (`transformers`, `torch` CPU build, `gradio`, and any tokenizer deps).
- `README.md` — the Space metadata header (SDK, etc.) plus a one-line description.

### Deliverables for Part 1
- The three files above, ready to paste into a new Gradio Space.
- The exact **API endpoint URL/format** the frontend should call, with an example request and example response payload, so the frontend can be wired to it without guessing.

---

## Part 2 — Frontend: chat widget in the Quarto site

### How it gets onto every page
- Quarto supports injecting raw HTML site-wide. Use an **`include-after-body`** entry in `_quarto.yml` pointing to a small HTML partial (e.g. `chat-widget.html`). This puts the widget on every page without editing individual `.qmd` files.
- All CSS and JS can live inside that single injected HTML file (self-contained), or be split into a `.css`/`.js` pair also referenced site-wide — pick the simplest option and state which.

### Widget UI/UX requirements
- A small **floating button** fixed in a screen corner (bottom-right is conventional). Clicking it toggles a **collapsible chat panel** open/closed.
- The panel contains: a scrollable message history, a text input, and a send button (Enter should also send).
- Show a clear **"waking up / thinking…" state.** Because the free Space can cold-start (~30–60s), the very first request may be slow. The UI must:
  - immediately show the user's message,
  - show a visible loading indicator,
  - not appear frozen or broken during a long first response,
  - ideally show a one-time note like "First reply may take up to a minute while the assistant wakes up."
- Handle errors gracefully: if the request fails or times out, show a friendly retry message rather than nothing.
- Keep a short **client-side conversation history** and send it with each request so the assistant has context (cap the length to avoid oversized requests).
- Mobile-friendly and responsive; the panel should be usable on a phone. Respect basic accessibility: keyboard focus, visible focus states, and reduced-motion friendliness.
- **Do not collect or store personal data.** No logins, no analytics on message content.

### Visual design direction
- The site targets pharmacy students learning R. Keep the widget clean, calm, and unintimidating — this audience is nervous about coding, so the tone (visual and written) should be reassuring, not "hacker terminal."
- Match or complement the existing Quarto theme rather than clashing with it. Use readable type, comfortable spacing, and a restrained accent color. Avoid the generic "AI chatbot" default look where reasonable; make one small, tasteful distinctive choice (e.g. a friendly greeting line, a subtle pill-shaped launcher) rather than a templated bubble.
- Render code in replies in a monospace block so R snippets are readable.

### Wiring to the backend
- The JS `fetch`es the Hugging Face Space endpoint (the exact URL/format from Part 1), sends the message + short history, and appends the returned reply to the chat.
- Use a generous client-side timeout to accommodate cold starts.

### Files to produce for Part 2
- `chat-widget.html` — the self-contained widget (markup + CSS + JS), with the backend URL clearly marked as a placeholder to fill in.
- The exact snippet to add to `_quarto.yml` under `format` → `html` → `include-after-body` (show where it goes).
- Any separate `.css`/`.js` files if you chose to split them.

### Deliverables for Part 2
- All widget files above.
- Clear instructions on where to put each file in the Quarto project and what to change in `_quarto.yml`.

---

## Part 3 — Integration & deployment steps (write these out explicitly)
1. Create the Hugging Face Space, add the three backend files, and wait for it to build/start.
2. Confirm the Space's API endpoint works (give a copy-paste test, e.g. a `curl` or browser-console `fetch` example).
3. Paste the endpoint URL into the widget's placeholder.
4. Add `chat-widget.html` to the Quarto project and register it in `_quarto.yml` via `include-after-body`.
5. `quarto render`, then push to the GitHub Pages branch/repo.
6. Load the live site, open the widget, and test a real R beginner question end-to-end (including the cold-start case).

## Testing checklist (the other AI should confirm all of these)
- Widget appears on every page and toggles open/closed.
- A question round-trips to the model and a reply appears.
- Cold-start (first request after idle) is handled with a visible loading state, not a frozen UI.
- CORS is correctly configured (no browser console CORS/mixed-content errors).
- Works on mobile and via keyboard.
- Answers are beginner-appropriate, short, and R-focused (system prompt is doing its job).
- Nothing in the stack requires payment or a credit card.

## Known tradeoffs to keep in mind (state these to the user, don't hide them)
- Free CPU inference is **slow** compared to hosted APIs; expect several seconds per reply even when warm, and up to ~a minute on cold start.
- A 1.5B model is **noticeably weaker** than a frontier model. It's fine for basic R syntax, common errors, and simple examples, but will struggle with complex or subtle questions. That's an acceptable tradeoff for $0 and this audience; note it so expectations are set.
- If usage grows or speed becomes a problem, the migration path is: move the backend to an always-on free VM (e.g. Oracle Cloud free tier) running Ollama, keeping the exact same frontend widget — only the endpoint URL changes.

## Output format requested from the building AI
Provide, in order: (1) the backend files with brief explanations, (2) the exact API endpoint details, (3) the frontend widget file(s), (4) the `_quarto.yml` change, (5) step-by-step deployment instructions, (6) confirmation against the testing checklist. Keep code complete and copy-pasteable, with placeholders clearly marked.
