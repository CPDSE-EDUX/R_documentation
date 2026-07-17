/**
 * Cloudflare Worker: proxy between the R Tutor chat widget (chat-widget.html)
 * and the Gemini API. Holds the API key as a Worker secret (GEMINI_API_KEY)
 * so it never appears in the public website.
 *
 * Deployed by pasting this file into the Cloudflare dashboard — see README.md.
 * Editing this file in git does NOT redeploy the Worker.
 */

var MODEL = "gemini-3.5-flash";

var ALLOWED_ORIGINS = [
  "https://cpdse-edux.github.io",
  // Local development (quarto preview on any port):
  "http://localhost",
  "http://127.0.0.1"
];

// Hard caps so a hijacked client cannot burn tokens on huge prompts.
var MAX_SYSTEM_CHARS = 16000;
var MAX_CONTENTS_ENTRIES = 21; // 10 history turns (2 each) + final question
var MAX_TOTAL_CHARS = 60000;

function isAllowedOrigin(origin) {
  if (!origin) return false;
  return ALLOWED_ORIGINS.some(function (allowed) {
    return origin === allowed || origin.indexOf(allowed + ":") === 0;
  });
}

function corsHeaders(origin) {
  return {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Content-Type": "application/json"
  };
}

function jsonResponse(status, payload, origin) {
  return new Response(JSON.stringify(payload), {
    status: status,
    headers: corsHeaders(origin)
  });
}

function validateBody(body) {
  if (!body || typeof body !== "object") return false;
  if (typeof body.system !== "string" || body.system.length > MAX_SYSTEM_CHARS) return false;
  if (body.system.indexOf("R Tutor") === -1) return false;
  if (!Array.isArray(body.contents) || body.contents.length < 1) return false;
  if (body.contents.length > MAX_CONTENTS_ENTRIES) return false;

  var totalChars = body.system.length;
  for (var i = 0; i < body.contents.length; i += 1) {
    var entry = body.contents[i];
    if (!entry || (entry.role !== "user" && entry.role !== "model")) return false;
    if (!Array.isArray(entry.parts) || entry.parts.length !== 1) return false;
    if (typeof entry.parts[0].text !== "string") return false;
    totalChars += entry.parts[0].text.length;
  }
  return totalChars <= MAX_TOTAL_CHARS;
}

export default {
  async fetch(request, env) {
    var origin = request.headers.get("Origin") || "";
    if (!isAllowedOrigin(origin)) {
      return new Response("Forbidden", { status: 403 });
    }
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders(origin) });
    }
    if (request.method !== "POST") {
      return jsonResponse(405, { error: "method_not_allowed" }, origin);
    }

    var body = null;
    try {
      body = await request.json();
    } catch (err) {
      body = null;
    }
    if (!validateBody(body)) {
      return jsonResponse(400, { error: "bad_request" }, origin);
    }

    var geminiRequest = {
      systemInstruction: { parts: [{ text: body.system }] },
      contents: body.contents,
      generationConfig: {
        temperature: 0.3,
        // Thinking tokens share this budget on Gemini 3/2.5, so keep it generous
        // and keep thinking low, or short answers get truncated mid-sentence.
        maxOutputTokens: 2048,
        thinkingConfig: { thinkingLevel: "low" }
      }
    };

    var upstream;
    try {
      upstream = await fetch(
        "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL + ":generateContent",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-goog-api-key": env.GEMINI_API_KEY
          },
          body: JSON.stringify(geminiRequest)
        }
      );
    } catch (err) {
      return jsonResponse(502, { error: "upstream_error" }, origin);
    }

    if (upstream.status === 429) {
      return jsonResponse(429, { error: "rate_limited" }, origin);
    }
    if (!upstream.ok) {
      return jsonResponse(502, { error: "upstream_error" }, origin);
    }

    var data = await upstream.json();
    var candidate = data.candidates && data.candidates[0];
    var reply = "";
    if (candidate && candidate.content && Array.isArray(candidate.content.parts)) {
      reply = candidate.content.parts
        .map(function (part) { return part.text || ""; })
        .join("");
    }
    if (!reply.trim()) {
      return jsonResponse(502, { error: "empty_reply" }, origin);
    }

    return jsonResponse(200, { reply: reply }, origin);
  }
};
