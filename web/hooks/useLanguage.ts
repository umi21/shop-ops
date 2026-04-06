'use client';

import { useLocale } from 'next-intl';
import { setLocaleInStorage, Locale } from '@/i18n';

/**
 * Custom hook for managing language preferences in the application.
 * Provides access to the current language and a function to change it.
 * 
 * @returns Object containing currentLanguage and changeLanguage function
 */
export function useLanguage() {
  const locale = useLocale() as Locale;

  /**
   * Changes the application language and persists the preference.
   * Dispatches a custom event to trigger UI updates across the application.
   * 
   * @param newLocale - The locale to switch to ('en' or 'am')
   */
  const changeLanguage = (newLocale: Locale) => {
    setLocaleInStorage(newLocale);
    
    // Dispatch custom event to trigger provider update
    window.dispatchEvent(
      new CustomEvent('localeChange', { detail: { locale: newLocale } })
    );
  };

  return {
    currentLanguage: locale,
    changeLanguage,
  };
}
