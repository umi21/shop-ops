import { renderHook, act } from '@testing-library/react';
import { useLanguage } from './useLanguage';
import { setLocaleInStorage, Locale } from '@/i18n';

// Mock the i18n module
jest.mock('@/i18n', () => ({
  setLocaleInStorage: jest.fn(),
  locales: ['en', 'am'],
}));

// Mock next-intl
jest.mock('next-intl', () => ({
  useLocale: jest.fn(),
}));

import { useLocale } from 'next-intl';

describe('useLanguage', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Reset any event listeners
    window.dispatchEvent = jest.fn(window.dispatchEvent);
  });

  describe('Current Language', () => {
    it('should return current language from useLocale', () => {
      (useLocale as jest.Mock).mockReturnValue('en');

      const { result } = renderHook(() => useLanguage());

      expect(result.current.currentLanguage).toBe('en');
    });

    it('should return Amharic when locale is am', () => {
      (useLocale as jest.Mock).mockReturnValue('am');

      const { result } = renderHook(() => useLanguage());

      expect(result.current.currentLanguage).toBe('am');
    });
  });

  describe('Change Language Function', () => {
    it('should persist language preference to storage when changeLanguage is called', () => {
      (useLocale as jest.Mock).mockReturnValue('en');

      const { result } = renderHook(() => useLanguage());

      act(() => {
        result.current.changeLanguage('am' as Locale);
      });

      expect(setLocaleInStorage).toHaveBeenCalledWith('am');
    });

    it('should dispatch localeChange event when changeLanguage is called', () => {
      (useLocale as jest.Mock).mockReturnValue('en');
      const dispatchEventSpy = jest.spyOn(window, 'dispatchEvent');

      const { result } = renderHook(() => useLanguage());

      act(() => {
        result.current.changeLanguage('am' as Locale);
      });

      expect(dispatchEventSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          type: 'localeChange',
          detail: { locale: 'am' },
        })
      );
    });

    it('should dispatch event with correct locale when changing to English', () => {
      (useLocale as jest.Mock).mockReturnValue('am');
      const dispatchEventSpy = jest.spyOn(window, 'dispatchEvent');

      const { result } = renderHook(() => useLanguage());

      act(() => {
        result.current.changeLanguage('en' as Locale);
      });

      expect(dispatchEventSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          type: 'localeChange',
          detail: { locale: 'en' },
        })
      );
      expect(setLocaleInStorage).toHaveBeenCalledWith('en');
    });
  });

  describe('Hook Return Value', () => {
    it('should return an object with currentLanguage and changeLanguage', () => {
      (useLocale as jest.Mock).mockReturnValue('en');

      const { result } = renderHook(() => useLanguage());

      expect(result.current).toHaveProperty('currentLanguage');
      expect(result.current).toHaveProperty('changeLanguage');
      expect(typeof result.current.changeLanguage).toBe('function');
    });

    it('should provide changeLanguage function on each render', () => {
      (useLocale as jest.Mock).mockReturnValue('en');

      const { result, rerender } = renderHook(() => useLanguage());
      const firstChangeLanguage = result.current.changeLanguage;

      expect(typeof firstChangeLanguage).toBe('function');

      rerender();

      // The function may be recreated, but it should still work correctly
      expect(typeof result.current.changeLanguage).toBe('function');
    });
  });

  describe('Multiple Language Changes', () => {
    it('should handle multiple language changes correctly', () => {
      (useLocale as jest.Mock).mockReturnValue('en');
      const dispatchEventSpy = jest.spyOn(window, 'dispatchEvent');

      const { result } = renderHook(() => useLanguage());

      // Change to Amharic
      act(() => {
        result.current.changeLanguage('am' as Locale);
      });

      expect(setLocaleInStorage).toHaveBeenCalledWith('am');
      expect(dispatchEventSpy).toHaveBeenCalledTimes(1);

      // Change back to English
      act(() => {
        result.current.changeLanguage('en' as Locale);
      });

      expect(setLocaleInStorage).toHaveBeenCalledWith('en');
      expect(dispatchEventSpy).toHaveBeenCalledTimes(2);
    });
  });
});
