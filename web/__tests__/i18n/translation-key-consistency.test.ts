/**
 * Property-Based Test: Translation Key Consistency Across Locales
 * 
 * Feature: amharic-localization
 * Property 1: Translation Key Consistency Across Locales
 * 
 * **Validates: Requirements 2.4, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8**
 * 
 * For any translation key that exists in the English translation file,
 * the same key must exist in the Amharic translation file with a non-empty value.
 */

import fc from 'fast-check';
import enTranslations from '@/messages/en.json';
import amTranslations from '@/messages/am.json';

describe('Translation Key Consistency', () => {
  /**
   * Helper function to flatten nested translation objects into dot-notation keys
   * Example: { common: { appName: "Shop Ops" } } => { "common.appName": "Shop Ops" }
   */
  function flattenTranslations(obj: any, prefix = ''): Record<string, string> {
    const result: Record<string, string> = {};
    
    for (const key in obj) {
      const fullKey = prefix ? `${prefix}.${key}` : key;
      
      if (typeof obj[key] === 'object' && obj[key] !== null && !Array.isArray(obj[key])) {
        // Recursively flatten nested objects
        Object.assign(result, flattenTranslations(obj[key], fullKey));
      } else {
        // Leaf node - store the value
        result[fullKey] = obj[key];
      }
    }
    
    return result;
  }

  const flatEnTranslations = flattenTranslations(enTranslations);
  const flatAmTranslations = flattenTranslations(amTranslations);
  const allEnglishKeys = Object.keys(flatEnTranslations);

  describe('Property 1: Translation Key Consistency Across Locales', () => {
    it('should have all English keys present in Amharic translations with non-empty values', () => {
      fc.assert(
        fc.property(
          fc.constantFrom(...allEnglishKeys),
          (key) => {
            // Check that the key exists in Amharic translations
            expect(key in flatAmTranslations).toBe(true);
            
            // Check that the Amharic translation is not empty
            const amharicValue = flatAmTranslations[key];
            expect(amharicValue).toBeTruthy();
            expect(typeof amharicValue).toBe('string');
            expect(amharicValue.trim().length).toBeGreaterThan(0);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should have matching structure between English and Amharic translation files', () => {
      // Verify that both files have the same top-level keys
      const enTopLevelKeys = Object.keys(enTranslations).sort();
      const amTopLevelKeys = Object.keys(amTranslations).sort();
      
      expect(amTopLevelKeys).toEqual(enTopLevelKeys);
    });

    it('should have the same number of translation keys in both locales', () => {
      const enKeyCount = allEnglishKeys.length;
      const amKeyCount = Object.keys(flatAmTranslations).length;
      
      expect(amKeyCount).toBe(enKeyCount);
    });

    it('should not have any extra keys in Amharic that are not in English', () => {
      const amharicKeys = Object.keys(flatAmTranslations);
      
      amharicKeys.forEach(key => {
        expect(allEnglishKeys).toContain(key);
      });
    });
  });
});
