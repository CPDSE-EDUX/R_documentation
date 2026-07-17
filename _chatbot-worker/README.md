# R Tutor chatbot — Cloudflare Worker backend

The chat widget ([../chat-widget.html](../chat-widget.html)) sends each question, together with
excerpts retrieved from this website's `search.json`, to a small Cloudflare Worker.
The Worker adds the Gemini API key (stored as a Worker **secret**, never in this
public repo) and forwards the request to Google's Gemini API.

- `worker.js` — the complete Worker source. **This folder is version control only:
  editing `worker.js` in git does NOT redeploy anything.** To deploy a change, paste
  the file into the Cloudflare dashboard again (step 4 below).
- The folder name starts with `_` so Quarto ignores it (not rendered, not copied to `_site`).

## One-time setup (~10 minutes, no command line)

1. **Get a free Gemini API key**: go to <https://aistudio.google.com/apikey>, sign in
   with a Google account, click *Create API key*. Free tier, no credit card.
2. **Create a free Cloudflare account** at <https://dash.cloudflare.com/sign-up>.
3. **Create the Worker**: dashboard → *Workers & Pages* → *Create* → *Create Worker*.
   Name it e.g. `cpdse-r-tutor`, click *Deploy* (deploys a hello-world first).
4. **Paste the code**: click *Edit code*, replace everything with the contents of
   `worker.js`, click *Deploy*.
5. **Add the API key as a secret**: Worker → *Settings* → *Variables and Secrets* →
   *Add* → type **Secret**, name `GEMINI_API_KEY`, paste the key from step 1 → save/deploy.
   (If the dashboard layout has changed, search the Worker settings for "secret".)
6. **Connect the widget**: copy the Worker URL (looks like
   `https://cpdse-r-tutor.<your-account>.workers.dev`) and paste it as `API_URL`
   near the top of the `<script>` in `chat-widget.html`. Commit and push — the
   chat launcher button appears automatically once `API_URL` is set to a real URL.

## Quick test (optional)

From a terminal (or use any HTTP tool):

```
curl -X POST "https://cpdse-r-tutor.<your-account>.workers.dev" ^
  -H "Origin: http://localhost:4200" ^
  -H "Content-Type: application/json" ^
  -d "{\"system\":\"You are R Tutor.\",\"contents\":[{\"role\":\"user\",\"parts\":[{\"text\":\"hi\"}]}]}"
```

Expected: `{"reply":"..."}`. With a disallowed `Origin` header you should get `403 Forbidden`.

## Maintenance

- **Model**: the `MODEL` constant at the top of `worker.js` (currently
  `gemini-3.5-flash`). Free-tier limits (July 2026): roughly 10 requests/minute and
  ~1,500 requests/day per key — shared by everyone using the chatbot. The widget
  shows a friendly "usage limit" message on 429 responses.
- **Allowed origins**: `ALLOWED_ORIGINS` in `worker.js`. Add the new domain if the
  site ever moves off `cpdse-edux.github.io`; `localhost`/`127.0.0.1` are allowed for
  `quarto preview` testing.
- **Rotate the key**: create a new key in AI Studio, update the `GEMINI_API_KEY`
  secret in the Worker settings, delete the old key in AI Studio.
- **Prompt / retrieval tuning** lives in `chat-widget.html` (system prompt, context
  size, scoring) — no Worker redeploy needed for those changes.
