import type { MealType, SaveMealRequest } from "../types";
import { validateDateYYYYMMDD as isDate } from "./date";

const mealTypes: MealType[] = ["breakfast", "lunch", "dinner", "snack", "other"];

export function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

export function validateDateYYYYMMDD(value: unknown): value is string {
  return typeof value === "string" && isDate(value);
}

export function validateMealType(value: unknown): value is MealType {
  return typeof value === "string" && mealTypes.includes(value as MealType);
}

export function validateParseFoodRequest(body: unknown): { ok: true; value: { text: string; locale?: string } } | { ok: false; message: string } {
  if (!body || typeof body !== "object") return { ok: false, message: "Request body is required" };
  const value = body as Record<string, unknown>;
  if (!isNonEmptyString(value.text)) return { ok: false, message: "Text is required" };
  if (value.locale !== undefined && typeof value.locale !== "string") return { ok: false, message: "Locale must be a string" };
  return { ok: true, value: { text: value.text.trim(), locale: value.locale } };
}

export function validatePreviewFoodRequest(body: unknown): { ok: true; value: { items: Array<{ canonicalName: string; quantity?: number; unit?: string; grams?: number }> } } | { ok: false; message: string } {
  if (!body || typeof body !== "object") return { ok: false, message: "Request body is required" };
  const value = body as Record<string, unknown>;
  if (!Array.isArray(value.items) || value.items.length === 0) return { ok: false, message: "Items are required" };

  const items = [];
  for (const item of value.items) {
    if (!item || typeof item !== "object") return { ok: false, message: "Each item must be an object" };
    const candidate = item as Record<string, unknown>;
    if (!isNonEmptyString(candidate.canonicalName)) return { ok: false, message: "Item canonicalName is required" };
    if (candidate.grams !== undefined && (typeof candidate.grams !== "number" || candidate.grams <= 0)) return { ok: false, message: "Item grams must be positive" };
    if (candidate.quantity !== undefined && typeof candidate.quantity !== "number") return { ok: false, message: "Item quantity must be a number" };
    if (candidate.unit !== undefined && typeof candidate.unit !== "string") return { ok: false, message: "Item unit must be a string" };
    items.push({
      canonicalName: candidate.canonicalName.trim(),
      quantity: typeof candidate.quantity === "number" ? candidate.quantity : undefined,
      unit: typeof candidate.unit === "string" ? candidate.unit : undefined,
      grams: typeof candidate.grams === "number" ? candidate.grams : undefined,
    });
  }

  return { ok: true, value: { items } };
}

export function validateSaveMealRequest(body: unknown): { ok: true; value: SaveMealRequest } | { ok: false; message: string } {
  if (!body || typeof body !== "object") return { ok: false, message: "Request body is required" };
  const value = body as Record<string, unknown>;
  if (!validateDateYYYYMMDD(value.date)) return { ok: false, message: "Valid date is required" };
  if (!validateMealType(value.mealType)) return { ok: false, message: "Valid mealType is required" };
  if (!Array.isArray(value.items) || value.items.length === 0) return { ok: false, message: "Items are required" };

  const items = [];
  for (const item of value.items) {
    if (!item || typeof item !== "object") return { ok: false, message: "Each item must be an object" };
    const candidate = item as Record<string, unknown>;
    if (!isNonEmptyString(candidate.foodName)) return { ok: false, message: "Item foodName is required" };
    if (typeof candidate.grams !== "number" || candidate.grams <= 0) return { ok: false, message: "Item grams must be positive" };
    for (const key of ["calories", "proteinG", "carbsG", "fatG", "fiberG", "sugarG", "sodiumMg", "calciumMg", "ironMg", "potassiumMg"]) {
      if (typeof candidate[key] !== "number") return { ok: false, message: `Item ${key} must be a number` };
    }
    items.push(candidate);
  }

  return {
    ok: true,
    value: {
      date: value.date,
      mealType: value.mealType,
      notes: typeof value.notes === "string" ? value.notes : undefined,
      items: items as SaveMealRequest["items"],
    },
  };
}

export function validateProfileRequest(body: unknown): { ok: true; value: Record<string, unknown> } | { ok: false; message: string } {
  if (!body || typeof body !== "object") return { ok: false, message: "Request body is required" };
  const value = body as Record<string, unknown>;
  const numericFields = ["age", "heightCm", "weightKg", "dailyCalorieGoal", "proteinGoalG", "carbsGoalG", "fatGoalG"];
  for (const field of numericFields) {
    if (value[field] !== undefined && value[field] !== null && typeof value[field] !== "number") {
      return { ok: false, message: `${field} must be a number` };
    }
  }
  return { ok: true, value };
}
