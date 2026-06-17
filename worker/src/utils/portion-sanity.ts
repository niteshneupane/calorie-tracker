/**
 * Portion sanity bounds.
 *
 * Purpose: prevent absurd estimates like "1 egg = 500g" or "1 cup of rice = 5g".
 * These are realistic min/max gram ranges for common units and food categories.
 * We clamp AI/USDA estimates to these ranges before returning to the client.
 */

export type PortionBounds = { min: number; max: number; typical: number };

/** Unit-level bounds — applied first regardless of food type */
const UNIT_BOUNDS: Record<string, PortionBounds> = {
  // Discrete countable items
  egg: { min: 40, max: 80, typical: 55 },
  piece: { min: 20, max: 300, typical: 100 },
  pcs: { min: 20, max: 300, typical: 100 },
  slice: { min: 15, max: 120, typical: 40 },

  // Volume-based
  cup: { min: 100, max: 350, typical: 240 },
  glass: { min: 150, max: 400, typical: 250 },
  teaspoon: { min: 3, max: 10, typical: 5 },
  tablespoon: { min: 10, max: 25, typical: 15 },
  ml: { min: 1, max: 2000, typical: 200 },

  // Serving descriptors
  serving: { min: 50, max: 600, typical: 200 },
  thali: { min: 400, max: 900, typical: 650 },
  plate: { min: 200, max: 700, typical: 350 },
  bowl: { min: 150, max: 600, typical: 300 },
  handful: { min: 20, max: 100, typical: 40 },

  // Weight
  g: { min: 1, max: 2000, typical: 100 },
  kg: { min: 100, max: 2000, typical: 500 },
  oz: { min: 10, max: 500, typical: 100 },
};

/**
 * Category-level typical serving sizes — used when unit gives too wide a range.
 * Keyed on rough food category keywords detected in the canonical name.
 */
const CATEGORY_TYPICAL: Array<{ keywords: string[]; typical: number; min: number; max: number }> = [
  { keywords: ["egg", "anda"], typical: 55, min: 40, max: 80 },
  { keywords: ["momo", "dumpling"], typical: 25, min: 15, max: 40 }, // per piece
  { keywords: ["roti", "chapati", "naan", "paratha"], typical: 45, min: 30, max: 120 },
  { keywords: ["rice", "bhat", "biryani", "fried rice"], typical: 180, min: 100, max: 400 },
  { keywords: ["dal", "lentil", "soup", "thukpa"], typical: 250, min: 150, max: 450 },
  { keywords: ["curry", "tarkari", "sabzi", "masu"], typical: 200, min: 120, max: 350 },
  { keywords: ["chowmein", "noodle", "pasta"], typical: 350, min: 200, max: 500 },
  { keywords: ["tea", "chiya", "chai", "coffee"], typical: 200, min: 100, max: 350 },
  { keywords: ["juice", "lassi", "smoothie", "shake"], typical: 250, min: 150, max: 500 },
  { keywords: ["banana", "apple", "orange", "mango", "fruit"], typical: 120, min: 50, max: 300 },
  { keywords: ["bread", "toast", "sandwich"], typical: 60, min: 30, max: 200 },
  { keywords: ["biscuit", "cookie", "cracker"], typical: 15, min: 8, max: 30 },
  { keywords: ["samosa", "pakora", "fritter"], typical: 80, min: 40, max: 150 },
  { keywords: ["sel roti", "sel"], typical: 75, min: 50, max: 120 },
  { keywords: ["chatpate", "pani puri", "panipuri", "snack"], typical: 150, min: 80, max: 300 },
  { keywords: ["chicken", "meat", "buff", "mutton", "fish"], typical: 150, min: 80, max: 300 },
  { keywords: ["milk", "dudh"], typical: 200, min: 100, max: 400 },
  { keywords: ["curd", "dahi", "yogurt"], typical: 150, min: 80, max: 250 },
  { keywords: ["butter", "ghee", "oil"], typical: 14, min: 5, max: 50 },
  { keywords: ["sugar", "honey", "jam"], typical: 20, min: 5, max: 60 },
  { keywords: ["thali", "dal bhat", "set meal"], typical: 650, min: 400, max: 900 },
];

/**
 * Returns the best gram estimate and its confidence bounds for a food + unit + quantity.
 *
 * @param canonicalName  normalised food name (lowercase)
 * @param unit           portion unit from the parser
 * @param quantity       how many of that unit
 * @param aiGrams        what the AI/USDA suggested (null if unknown)
 */
export function sanitiseGrams(
  canonicalName: string,
  unit: string | null,
  quantity: number,
  aiGrams: number | null,
): { grams: number; isAmbiguous: boolean } {
  const normName = canonicalName.toLowerCase();
  const normUnit = (unit ?? "serving").toLowerCase().trim();

  // 1. Look up unit bounds
  const unitBounds = UNIT_BOUNDS[normUnit] ?? UNIT_BOUNDS["serving"];

  // 2. Look up category typical
  const catMatch = CATEGORY_TYPICAL.find((c) => c.keywords.some((k) => normName.includes(k)));

  // 3. Decide per-item gram estimate (before multiplying by quantity)
  let perItemGrams: number;
  let isAmbiguous = false;

  if (aiGrams !== null) {
    // The AI gave us a total grams value — divide by quantity to get per-item, then clamp
    const perItem = aiGrams / quantity;
    const clampMin = Math.min(unitBounds.min, catMatch?.min ?? unitBounds.min);
    const clampMax = Math.max(unitBounds.max, catMatch?.max ?? unitBounds.max);
    perItemGrams = Math.min(Math.max(perItem, clampMin), clampMax);
  } else {
    // No AI estimate — use category typical if available, else unit typical
    perItemGrams = catMatch?.typical ?? unitBounds.typical;
    isAmbiguous = ["plate", "bowl", "serving", "thali"].includes(normUnit);
  }

  return {
    grams: Math.round(perItemGrams * quantity),
    isAmbiguous,
  };
}

/**
 * True if the portion is genuinely ambiguous (vague descriptor + no category match).
 * The caller should set needsManualSelection = true in this case.
 */
export function isAmbiguousPortion(unit: string | null, canonicalName: string): boolean {
  const vague = ["plate", "bowl", "serving", "some", "a bit", "handful"];
  const normUnit = (unit ?? "").toLowerCase();
  const normName = canonicalName.toLowerCase();
  if (!vague.includes(normUnit)) return false;
  // Even vague units are OK if we have a category match
  const hasCategoryMatch = CATEGORY_TYPICAL.some((c) => c.keywords.some((k) => normName.includes(k)));
  return !hasCategoryMatch;
}
