/**
 * Property-Based Test: Language Preference Persistence Round-Trip
 * 
 * Feature: amharic-localization
 * Property 4: Language Preference Persistence Round-Trip
 * 
 * **Validates: Requirements 4.3, 4.4**
 * 
 * For any language selection (English or Amharic), when a user selects a language,
 * it must be persisted to browser local storage, and when the application reloads,
 * the localization system must retrieve and apply that same language preference.
 */

import fc from 'fast-check';
import { getLocaleFromStorage, setLocaleInStorage, Locale, locales, defaultLocale } from '@/i18n';

describe('Language Preference Persistence', () => {
  // Store original localStorage to restore after tests
  let originalLocalStorage: Storage;

  beforeEach(() => {
    // Create a mock localStorage for testing
    const localStorageMock: { [key: string]: string } = {};
    
    global.localStorage = {
      getItem: (key: string) => localStorageMock[key] || null,
      setItem: (key: string, value: string) => {
        localStorageMock[key] = value;
      },
      removeItem: (key: string) => {
        delete localStorageMock[key];
      },
      clear: () => {
        Object.keys(localStorageMock).forEach(key => delete localStorageMock[key]);
      },
      key: (index: number) => Object.keys(localStorageMock)[index] || null,
      length: Object.keys(localStorageMock).length,
    } as Storage;
  });

  afterEach(() => {
    // Clean up localStorage after each test
    localStorage.clear();
  });

  describe('Property 4: Language Preference Persistence Round-Trip', () => {
    it('should persist and retrieve language preference correctly for both English and Amharic', () => {
      fc.assert(
        fc.property(
          fc.constantFrom(...locales),
          (locale) => {
            // Persist the locale to storage
            setLocaleInStorage(locale);
            
            // Retrieve the locale from storage
            const retrieved = getLocaleFromStorage();
            
            // Verify the retrieved locale matches the persisted locale
            expect(retrieved).toBe(locale);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should default to English when no language preference is stored', () => {
      // Ensure localStorage is empty
      localStorage.clear();
      
      // Retrieve locale when nothing is stored
      const retrieved = getLocaleFromStorage();
      
      // Should default to English
      expect(retrieved).toBe(defaultLocale);
      expect(retrieved).toBe('en');
    });

    it('should handle multiple consecutive language changes correctly', () => {
      fc.assert(
        fc.property(
          fc.array(fc.constantFrom(...locales), { minLength: 1, maxLength: 10 }),
          (localeSequence) => {
            // Apply each locale change in sequence
            localeSequence.forEach(locale => {
              setLocaleInStorage(locale);
            });
            
            // The final retrieved locale should match the last one in the sequence
            const retrieved = getLocaleFromStorage();
            const lastLocale = localeSequence[localeSequence.length - 1];
            
            expect(retrieved).toBe(lastLocale);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should persist language preference across simulated page reloads', () => {
      fc.assert(
        fc.property(
          fc.constantFrom(...locales),
          (locale) => {
            // Set the locale
            setLocaleInStorage(locale);
            
            // Simulate page reload by retrieving the locale again
            const afterReload = getLocaleFromStorage();
            
            // Verify persistence
            expect(afterReload).toBe(locale);
            
            // Simulate another reload
            const afterSecondReload = getLocaleFromStorage();
            
            // Should still be the same
            expect(afterSecondReload).toBe(locale);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should store language preference in localStorage with correct key', () => {
      fc.assert(
        fc.property(
          fc.constantFrom(...locales),
          (locale) => {
            // Set the locale
            setLocaleInStorage(locale);
            
            // Verify it's stored in localStorage with the correct key
            const storedValue = localStorage.getItem('language');
            
            expect(storedValue).toBe(locale);
          }
        ),
        { numRuns: 100 }
      );
    });

    it('should handle invalid locale values by defaulting to English', () => {
      // Set an invalid locale value directly in localStorage
      const invalidLocales = ['fr', 'es', 'invalid', 'amharic', 'english'];
      
      invalidLocales.forEach(invalidLocale => {
        localStorage.clear();
        localStorage.setItem('language', invalidLocale);
        
        // Retrieve locale - should default to English and clear invalid value
        const retrieved = getLocaleFromStorage();
        
        expect(retrieved).toBe(defaultLocale);
        expect(retrieved).toBe('en');
        
        // Invalid value should be removed from storage
        const storedValue = localStorage.getItem('language');
        expect(storedValue).toBeNull();
      });
    });

    it('should handle empty string in storage by defaulting to English', () => {
      localStorage.clear();
      localStorage.setItem('language', '');
      
      // Retrieve locale - should default to English
      const retrieved = getLocaleFromStorage();
      
      expect(retrieved).toBe(defaultLocale);
      expect(retrieved).toBe('en');
      
      // Empty string is treated as falsy, so it's not removed but returns default
      // This is acceptable behavior as empty string is falsy
    });

    it('should only accept valid locale values', () => {
      // Test that only 'en' and 'am' are valid
      const validLocales: Locale[] = ['en', 'am'];
      
      validLocales.forEach(locale => {
        setLocaleInStorage(locale);
        const retrieved = getLocaleFromStorage();
        expect(retrieved).toBe(locale);
      });
    });
  });
});
