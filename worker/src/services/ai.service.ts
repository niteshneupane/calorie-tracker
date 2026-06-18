import type { Bindings, ParseFoodResponse, ParsedFoodItem } from "../types";

export async function parseFoodText(env: Bindings, text: string, locale = "en-US"): Promise<ParseFoodResponse> {
  const cacheKey = normalizeCacheKey(text, locale);
  const cached = await env.FOOD_PARSE_CACHE.get(cacheKey, "json").catch(() => null);
  if (cached && isParseFoodResponse(cached)) return cached;

  let parsed: ParseFoodResponse | null = null;
  try {
    const messages = [
      { role: "system", content: "You are a food-mapping assistant. Output only in START_FOOD/END_FOOD blocks as instructed. Do NOT use JSON or markdown." },
      { role: "user", content: buildFoodParserPrompt(text, locale) },
    ];
    console.log("[AI DEBUG] parse prompt:", JSON.stringify(messages));

    const rawAiResponse = await env.AI.run("@cf/moonshotai/kimi-k2.7-code", { messages });

    console.log("[AI DEBUG] parse raw response:", JSON.stringify(rawAiResponse));

    // Try START_FOOD/END_FOOD text block parser first (matches current prompt format)
    parsed = parseStartFoodBlocks(rawAiResponse);

    // Fall back to JSON parser
    if (!parsed) {
      const candidate = safeJsonParseAiResponse(rawAiResponse);
      parsed = isParseFoodResponse(candidate) ? candidate : null;
    }
  } catch (error) {
    console.log("AI_ERROR", String(error));
  }

  parsed ??= fallbackParseFoodText(text);

  await env.FOOD_PARSE_CACHE.put(cacheKey, JSON.stringify(parsed), { expirationTtl: 60 * 60 * 24 * 30 }).catch(() => {});
  return parsed;
}

export function buildFoodParserPrompt(text: string, locale = "en-US"): string {
  return [
   "You are a food-mapping assistant for a Nepal-focused calorie tracker.  \n" +
   "The user describes food in Nepali, Romanized Nepali, English, or mixed language.  \n" +
   "Map it to the closest USDA FoodData Central (FDC) canonical name and estimate a realistic portion in grams.\n" +
   "\n" +
   "Return output in this exact format. Do not use markdown code blocks. Use plain text only.\n" +
   "\n" +
   "START_FOOD\n" +
   "user_input: <exact user input>\n" +
   "canonical_fdc_name: <best English canonical name for FDC search>\n" +
   "fdc_keywords: <keyword1> | <keyword2> | <keyword3>\n" +
   "portion_grams: <number>\n" +
   "portion_description: <how you interpreted the portion>\n" +
   "confidence: high | medium | low\n" +
   "food_tags: <tag1> | <tag2> | <tag3> | <tag4>\n" +
   "nepali_equivalent: <Nepali name in Devanagari if known>\n" +
   "preparation_note: <short note about cooking method, variability, or local context>\n" +
   "natural_summary: <1 sentence describing the food in plain English, useful for embeddings>\n" +
   "END_FOOD\n" +
   "\n" +
   "Rules:\n" +
   "- Use \"canonical_fdc_name\" from FDC-style names like \"Beef, cured, dried\", \"Rice, white, long-grain, cooked\", \"Momo\" is not in FDC so pick nearest like \"Dumpling, meat-filled, steamed\".\n" +
   "- If a dish is mixed (e.g., \"dal bhat\"), list each major component as a separate START_FOOD...END_FOOD block.\n" +
   "- If quantity is unclear, assume a standard single serving.\n" +
   "- For unknown or highly variable items, set confidence to low and explain in preparation_note.\n" +
   "\n" +
   "Example:\n" +
   "\n" +
   "Input: sukuti 2 stick\n" +
   "Output:\n" +
   "\n" +
   "START_FOOD\n" +
   "user_input: sukuti 2 stick\n" +
   "canonical_fdc_name: Beef, cured, dried\n" +
   "fdc_keywords: beef cured dried | beef jerky | dried buffalo meat\n" +
   "portion_grams: 100\n" +
   "portion_description: 2 sticks of sukuti, approximately 50 g each\n" +
   "confidence: medium\n" +
   "food_tags: nepali | street-food | dried-meat | high-sodium | snack\n" +
   "nepali_equivalent: सुकुटी\n" +
   "preparation_note: Sukuti is usually dried buffalo, goat, or beef with spices and salt. Sodium and fat vary by vendor.\n" +
   "natural_summary: Two sticks of Nepali dried spiced meat, commonly made from buffalo or beef, eaten as a snack.\n" +
   "END_FOOD\n" +
   "\n" +
   "Now process this input:\n" +
   "\n" +
   text
  ].join("\n");
}

export function safeJsonParseAiResponse(response: unknown): unknown {
  const candidate = extractResponseText(response);
  if (typeof candidate !== "string") return candidate;
  const withoutFences = candidate.replace(/```(?:json)?/gi, "```").replace(/```/g, "").trim();

  try {
    return JSON.parse(withoutFences);
  } catch {
    const extracted = extractFirstJsonObject(withoutFences);
    if (!extracted) throw new Error("Unable to parse AI JSON response");
    return JSON.parse(extracted);
  }
}

export function normalizeCacheKey(text: string, locale = "en-US"): string {
  const normalized = text.trim().toLowerCase().replace(/\s+/g, " ");
  return `food-parse:${locale.toLowerCase()}:${normalized}`;
}

function extractResponseText(response: unknown): unknown {
  if (typeof response === "string") return response;
  if (!response || typeof response !== "object") return response;
  const object = response as Record<string, unknown>;

  // OpenAI-compatible chat format: choices[0].message.content
  const choices = object.choices;
  if (Array.isArray(choices) && choices.length > 0) {
    const msg = choices[0]?.message;
    if (msg && typeof msg.content === "string") return msg.content;
  }

  if (typeof object.response === "string") return object.response;
  if (object.response && typeof object.response === "object") return object.response;

  return response;
}

function extractFirstJsonObject(text: string): string | null {
  const start = text.indexOf("{");
  if (start === -1) return null;

  let depth = 0;
  let inString = false;
  let escaped = false;
  for (let index = start; index < text.length; index += 1) {
    const char = text[index];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char === "\\") {
        escaped = true;
      } else if (char === '"') {
        inString = false;
      }
      continue;
    }
    if (char === '"') inString = true;
    if (char === "{") depth += 1;
    if (char === "}") depth -= 1;
    if (depth === 0) return text.slice(start, index + 1);
  }
  return null;
}

export function isParseFoodResponse(value: unknown): value is ParseFoodResponse {
  return Boolean(value && typeof value === "object" && Array.isArray((value as ParseFoodResponse).items));
}

// ---------------------------------------------------------------------------
// START_FOOD / END_FOOD text block parser
// ---------------------------------------------------------------------------

function parseStartFoodBlocks(response: unknown): ParseFoodResponse | null {
  const text = extractResponseText(response);
  if (typeof text !== "string") return null;

  const items: ParsedFoodItem[] = [];

  // 1. Try strict START_FOOD ... END_FOOD blocks with newline padding
  const blockRegex = /START_FOOD\s*\n([\s\S]*?)\n\s*END_FOOD/g;
  let match: RegExpExecArray | null;
  while ((match = blockRegex.exec(text)) !== null) {
    const blockContent = match[1].trim();
    if (!blockContent) continue;
    const item = parseSingleFoodBlock(blockContent);
    if (item) items.push(item);
  }

  // 2. Try blocks without newline padding
  if (items.length === 0) {
    const looseRegex = /START_FOOD([\s\S]*?)END_FOOD/g;
    while ((match = looseRegex.exec(text)) !== null) {
      const blockContent = match[1].trim();
      if (!blockContent) continue;
      const item = parseSingleFoodBlock(blockContent);
      if (item) items.push(item);
    }
  }

  // 3. No START_FOOD marker at all — try parsing the whole text as one block
  if (items.length === 0) {
    const endFoodIndex = text.indexOf("END_FOOD");
    const blockContent = endFoodIndex !== -1
      ? text.slice(0, endFoodIndex).trim()
      : text.trim();
    if (blockContent && blockContent.includes("canonical_fdc_name")) {
      const item = parseSingleFoodBlock(blockContent);
      if (item) items.push(item);
    }
  }

  return items.length > 0 ? { items } : null;
}

function parseSingleFoodBlock(block: string): ParsedFoodItem | null {
  const fields: Record<string, string> = {};

  for (const line of block.split("\n")) {
    const colonIndex = line.indexOf(":");
    if (colonIndex === -1) continue;
    const key = line.slice(0, colonIndex).trim();
    const value = line.slice(colonIndex + 1).trim();
    fields[key] = value;
  }

  const canonicalName = fields["canonical_fdc_name"];
  if (!canonicalName) return null;

  const userInput = fields["user_input"] ?? "";

  return {
    rawText: userInput,
    canonicalName,
    quantity: extractQuantity(userInput),
    unit: extractUnit(userInput) ?? "serving",
    estimatedGrams: parseFloatOrNull(fields["portion_grams"]),
    estimatedMl: null,
    confidence: parseConfidence(fields["confidence"]),
    possibleVariants: (fields["fdc_keywords"] ?? "").split("|").map((s) => s.trim()).filter(Boolean),
    fdcKeywords: fields["fdc_keywords"],
    portionDescription: fields["portion_description"],
    foodTags: (fields["food_tags"] ?? "").split("|").map((s) => s.trim()).filter(Boolean),
    nepaliEquivalent: fields["nepali_equivalent"] || undefined,
    preparationNote: fields["preparation_note"] || undefined,
    naturalSummary: fields["natural_summary"] || undefined,
  };
}

function parseFloatOrNull(value: string | undefined): number | null {
  if (!value) return null;
  const num = Number(value);
  return Number.isFinite(num) ? num : null;
}

function parseConfidence(value: string | undefined): number {
  switch ((value ?? "").toLowerCase().trim()) {
    case "high": return 0.85;
    case "medium": return 0.65;
    case "low": return 0.35;
    default: return 0.5;
  }
}

function fallbackParseFoodText(text: string): ParseFoodResponse {
  const normalized = text.trim().toLowerCase().replace(/\s+/g, " ");
  const quantity = extractQuantity(normalized);
  const match = foodPatterns.find((pattern) => pattern.patterns.some((name) => normalized.includes(name)));

  if (!match) {
    return {
      items: [
        {
          rawText: text,
          canonicalName: normalized,
          quantity,
          unit: extractUnit(normalized) ?? "serving",
          estimatedGrams: null,
          estimatedMl: null,
          confidence: 0.3,
          possibleVariants: [],
        },
      ],
    };
  }

  return {
    items: [
      {
        rawText: text,
        canonicalName: match.canonicalName,
        quantity,
        unit: extractUnit(normalized) ?? match.unit,
        estimatedGrams: match.grams * quantity,
        estimatedMl: match.ml,
        confidence: 0.65,
        possibleVariants: match.variants,
      },
    ],
  };
}

const foodPatterns = [
  {
    patterns: ["chowmin", "chowmein", "noodles"],
    canonicalName: "vegetable chowmein",
    unit: "plate",
    grams: 350,
    ml: null,
    variants: ["vegetable chowmein", "chicken chowmein", "egg chowmein"],
  },
  {
    patterns: ["dal bhat", "daal bhat", "thali"],
    canonicalName: "dal bhat",
    unit: "thali",
    grams: 520,
    ml: null,
    variants: ["dal bhat", "rice and dal", "rice and curry"],
  },
  {
    patterns: ["momo", "momos"],
    canonicalName: "chicken momo",
    unit: "pcs",
    grams: 30,
    ml: null,
    variants: ["chicken momo", "buff momo", "vegetable momo"],
  },
  {
    patterns: ["boiled egg", "egg"],
    canonicalName: "boiled egg",
    unit: "piece",
    grams: 50,
    ml: null,
    variants: ["boiled egg"],
  },
  {
    patterns: ["milk tea", "chiya", "tea"],
    canonicalName: "milk tea",
    unit: "cup",
    grams: 240,
    ml: 240,
    variants: ["milk tea", "black tea"],
  },
];

function extractQuantity(text: string): number {
  const match = text.match(/\b(\d+(?:\.\d+)?)\b/);
  if (!match) return 1;
  const value = Number(match[1]);
  return Number.isFinite(value) && value > 0 ? value : 1;
}

function extractUnit(text: string): string | null {
  const units = "plate|thali|cup|bowl|pcs|pieces|piece|serving|egg|eggs|slice|glass|teaspoon|tablespoon|ml|l|handful|g|kg|oz";
  const match = text.match(new RegExp(`\\b(?:\\d+(?:\\.\\d+)?\\s*)?(${units})\\b`));
  if (!match) return null;
  if (match[1] === "eggs") return "egg";
  if (match[1] === "pieces") return "piece";
  return match[1];
}
