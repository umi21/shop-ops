export const locales = ['en', 'am'] as const;
export type Locale = typeof locales[number];

export const defaultLocale: Locale = 'en';

/**
 * Retrieves the user's language preference from browser local storage.
 * Falls back to the default locale if no preference is stored or if the stored value is invalid.
 * 
 * @returns The user's preferred locale or the default locale
 */
export function getLocaleFromStorage(): Locale {
  if (typeof window === 'undefined') return defaultLocale;
  
  const stored = localStorage.getItem('language');
  
  if (!stored) {
    return defaultLocale;
  }
  
  if (!locales.includes(stored as Locale)) {
    console.warn(`[i18n] Invalid locale in storage: "${stored}". Defaulting to English.`);
    localStorage.removeItem('language');
    return defaultLocale;
  }
  
  return stored as Locale;
}

/**
 * Persists the user's language preference to browser local storage.
 * 
 * @param locale - The locale to store
 */
export function setLocaleInStorage(locale: Locale): void {
  if (typeof window === 'undefined') return;
  localStorage.setItem('language', locale);
}
