'use client';

import { NextIntlClientProvider } from 'next-intl';
import { ReactNode, useState, useEffect } from 'react';
import { getLocaleFromStorage, defaultLocale, Locale } from '@/i18n';

type LocaleProviderProps = {
  children: ReactNode;
};

export default function LocaleProvider({ children }: LocaleProviderProps) {
  const [locale, setLocale] = useState<Locale>(defaultLocale);
  const [messages, setMessages] = useState<any>(null);

  useEffect(() => {
    const loadMessages = async () => {
      const currentLocale = getLocaleFromStorage();
      setLocale(currentLocale);
      
      const msgs = await import(`@/messages/${currentLocale}.json`);
      setMessages(msgs.default);
    };
    
    loadMessages();
  }, []);

  useEffect(() => {
    const handleLocaleChange = async (event: CustomEvent<{ locale: Locale }>) => {
      const newLocale = event.detail.locale;
      setLocale(newLocale);
      
      const msgs = await import(`@/messages/${newLocale}.json`);
      setMessages(msgs.default);
    };

    window.addEventListener('localeChange' as any, handleLocaleChange);
    return () => window.removeEventListener('localeChange' as any, handleLocaleChange);
  }, []);

  if (!messages) return null;

  return (
    <NextIntlClientProvider locale={locale} messages={messages}>
      {children}
    </NextIntlClientProvider>
  );
}
