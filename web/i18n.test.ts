import { getLocaleFromStorage, setLocaleInStorage, defaultLocale, locales } from './i18n';

describe('i18n Configuration', () => {
  let localStorageMock: { [key: string]: string };

  beforeEach(() => {
    // Mock localStorage
    localStorageMock = {};

    Object.defineProperty(window, 'localStorage', {
      value: {
        getItem: jest.fn((key: string) => localStorageMock[key] || null),
        setItem: jest.fn((key: string, value: string) => {
          localStorageMock[key] = value;
        }),
        removeItem: jest.fn((key: string) => {
          delete localStorageMock[key];
        }),
        clear: jest.fn(() => {
          localStorageMock = {};
        }),
      },
      writable: true,
    });

    // Mock console.warn to avoid cluttering test output
    jest.spyOn(console, 'warn').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('getLocaleFromStorage', () => {
    it('should return default locale when no preference is stored', () => {
      const locale = getLocaleFromStorage();
      expect(locale).toBe(defaultLocale);
      expect(locale).toBe('en');
    });

    it('should return stored locale when valid English preference exists', () => {
      localStorageMock['language'] = 'en';

      const locale = getLocaleFromStorage();
      expect(locale).toBe('en');
    });

    it('should return stored locale when valid Amharic preference exists', () => {
      localStorageMock['language'] = 'am';

      const locale = getLocaleFromStorage();
      expect(locale).toBe('am');
    });

    it('should default to English when invalid locale is stored', () => {
      localStorageMock['language'] = 'invalid-locale';

      const locale = getLocaleFromStorage();
      expect(locale).toBe('en');
    });

    it('should log warning when invalid locale is found in storage', () => {
      localStorageMock['language'] = 'fr';

      getLocaleFromStorage();

      expect(console.warn).toHaveBeenCalledWith(
        '[i18n] Invalid locale in storage: "fr". Defaulting to English.'
      );
    });

    it('should remove invalid locale from storage', () => {
      localStorageMock['language'] = 'invalid';

      getLocaleFromStorage();

      expect(window.localStorage.removeItem).toHaveBeenCalledWith('language');
    });

    it('should handle empty string in storage', () => {
      localStorageMock['language'] = '';

      const locale = getLocaleFromStorage();
      expect(locale).toBe('en');
    });

    it('should validate locale against allowed locales list', () => {
      // Test that only locales in the locales array are accepted
      expect(locales).toEqual(['en', 'am']);

      localStorageMock['language'] = 'es';
      const locale = getLocaleFromStorage();
      expect(locale).toBe('en');
    });
  });

  describe('setLocaleInStorage', () => {
    it('should persist English locale to storage', () => {
      setLocaleInStorage('en');

      expect(window.localStorage.setItem).toHaveBeenCalledWith('language', 'en');
      expect(localStorageMock['language']).toBe('en');
    });

    it('should persist Amharic locale to storage', () => {
      setLocaleInStorage('am');

      expect(window.localStorage.setItem).toHaveBeenCalledWith('language', 'am');
      expect(localStorageMock['language']).toBe('am');
    });

    it('should overwrite existing locale preference', () => {
      localStorageMock['language'] = 'en';

      setLocaleInStorage('am');

      expect(localStorageMock['language']).toBe('am');
    });

    it('should handle multiple consecutive updates', () => {
      setLocaleInStorage('en');
      expect(localStorageMock['language']).toBe('en');

      setLocaleInStorage('am');
      expect(localStorageMock['language']).toBe('am');

      setLocaleInStorage('en');
      expect(localStorageMock['language']).toBe('en');
    });
  });

  describe('Round-trip persistence', () => {
    it('should persist and retrieve English locale correctly', () => {
      setLocaleInStorage('en');
      const retrieved = getLocaleFromStorage();
      expect(retrieved).toBe('en');
    });

    it('should persist and retrieve Amharic locale correctly', () => {
      setLocaleInStorage('am');
      const retrieved = getLocaleFromStorage();
      expect(retrieved).toBe('am');
    });

    it('should handle multiple round-trips', () => {
      setLocaleInStorage('en');
      expect(getLocaleFromStorage()).toBe('en');

      setLocaleInStorage('am');
      expect(getLocaleFromStorage()).toBe('am');

      setLocaleInStorage('en');
      expect(getLocaleFromStorage()).toBe('en');
    });
  });

  describe('Edge Cases', () => {
    it('should handle null in storage', () => {
      localStorageMock['language'] = null as any;

      const locale = getLocaleFromStorage();
      expect(locale).toBe('en');
    });

    it('should handle undefined in storage', () => {
      localStorageMock['language'] = undefined as any;

      const locale = getLocaleFromStorage();
      expect(locale).toBe('en');
    });

    it('should handle numeric value in storage', () => {
      localStorageMock['language'] = '123';

      const locale = getLocaleFromStorage();
      expect(locale).toBe('en');
      expect(console.warn).toHaveBeenCalled();
    });

    it('should handle special characters in storage', () => {
      localStorageMock['language'] = '@#$%';

      const locale = getLocaleFromStorage();
      expect(locale).toBe('en');
      expect(console.warn).toHaveBeenCalled();
    });
  });

  describe('Type Safety', () => {
    it('should only accept valid Locale types for setLocaleInStorage', () => {
      // TypeScript compile-time check - these should compile
      setLocaleInStorage('en');
      setLocaleInStorage('am');

      // This would fail TypeScript compilation:
      // setLocaleInStorage('invalid');
    });

    it('should return Locale type from getLocaleFromStorage', () => {
      const locale = getLocaleFromStorage();
      
      // Verify the returned value is one of the valid locales
      expect(['en', 'am']).toContain(locale);
    });
  });
});
