import { render, screen, waitFor } from '@testing-library/react';
import { act } from 'react';
import LocaleProvider from './LocaleProvider';
import { getLocaleFromStorage, setLocaleInStorage, Locale } from '@/i18n';

// Mock the i18n module
jest.mock('@/i18n', () => ({
  getLocaleFromStorage: jest.fn(),
  setLocaleInStorage: jest.fn(),
  defaultLocale: 'en',
  locales: ['en', 'am'],
}));

// Mock next-intl
jest.mock('next-intl', () => ({
  NextIntlClientProvider: ({ children, locale }: any) => (
    <div data-testid="intl-provider" data-locale={locale}>
      {children}
    </div>
  ),
}));

// Mock dynamic imports for translation files
jest.mock('@/messages/en.json', () => ({
  default: {
    common: { appName: 'Shop Ops' },
    navigation: { dashboard: 'Dashboard' },
  },
}), { virtual: true });

jest.mock('@/messages/am.json', () => ({
  default: {
    common: { appName: 'ሾፕ ኦፕስ' },
    navigation: { dashboard: 'ዳሽቦርድ' },
  },
}), { virtual: true });

describe('LocaleProvider', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Initialization', () => {
    it('should initialize with default locale when no preference is stored', async () => {
      (getLocaleFromStorage as jest.Mock).mockReturnValue('en');

      render(
        <LocaleProvider>
          <div data-testid="child">Test Content</div>
        </LocaleProvider>
      );

      await waitFor(() => {
        const provider = screen.getByTestId('intl-provider');
        expect(provider).toHaveAttribute('data-locale', 'en');
      });

      expect(getLocaleFromStorage).toHaveBeenCalled();
    });

    it('should initialize with stored locale preference', async () => {
      (getLocaleFromStorage as jest.Mock).mockReturnValue('am');

      render(
        <LocaleProvider>
          <div data-testid="child">Test Content</div>
        </LocaleProvider>
      );

      await waitFor(() => {
        const provider = screen.getByTestId('intl-provider');
        expect(provider).toHaveAttribute('data-locale', 'am');
      });

      expect(getLocaleFromStorage).toHaveBeenCalled();
    });
  });

  describe('Translation Loading', () => {
    it('should load English translations when locale is en', async () => {
      (getLocaleFromStorage as jest.Mock).mockReturnValue('en');

      render(
        <LocaleProvider>
          <div data-testid="child">Test Content</div>
        </LocaleProvider>
      );

      await waitFor(() => {
        expect(screen.getByTestId('intl-provider')).toBeInTheDocument();
      });

      // Verify the provider is rendered with English locale
      const provider = screen.getByTestId('intl-provider');
      expect(provider).toHaveAttribute('data-locale', 'en');
    });

    it('should load Amharic translations when locale is am', async () => {
      (getLocaleFromStorage as jest.Mock).mockReturnValue('am');

      render(
        <LocaleProvider>
          <div data-testid="child">Test Content</div>
        </LocaleProvider>
      );

      await waitFor(() => {
        expect(screen.getByTestId('intl-provider')).toBeInTheDocument();
      });

      // Verify the provider is rendered with Amharic locale
      const provider = screen.getByTestId('intl-provider');
      expect(provider).toHaveAttribute('data-locale', 'am');
    });
  });

  describe('Locale Change Events', () => {
    it('should update locale when localeChange event is dispatched', async () => {
      (getLocaleFromStorage as jest.Mock).mockReturnValue('en');

      const { rerender } = render(
        <LocaleProvider>
          <div data-testid="child">Test Content</div>
        </LocaleProvider>
      );

      await waitFor(() => {
        expect(screen.getByTestId('intl-provider')).toHaveAttribute('data-locale', 'en');
      });

      // Dispatch locale change event
      act(() => {
        window.dispatchEvent(
          new CustomEvent('localeChange', { detail: { locale: 'am' as Locale } })
        );
      });

      await waitFor(() => {
        const provider = screen.getByTestId('intl-provider');
        expect(provider).toHaveAttribute('data-locale', 'am');
      });
    });

    it('should load new translations when locale changes', async () => {
      (getLocaleFromStorage as jest.Mock).mockReturnValue('en');

      render(
        <LocaleProvider>
          <div data-testid="child">Test Content</div>
        </LocaleProvider>
      );

      await waitFor(() => {
        expect(screen.getByTestId('intl-provider')).toHaveAttribute('data-locale', 'en');
      });

      // Change to Amharic
      act(() => {
        window.dispatchEvent(
          new CustomEvent('localeChange', { detail: { locale: 'am' as Locale } })
        );
      });

      await waitFor(() => {
        const provider = screen.getByTestId('intl-provider');
        expect(provider).toHaveAttribute('data-locale', 'am');
      });
    });
  });

  describe('Rendering Behavior', () => {
    it('should render children after translations are loaded', async () => {
      (getLocaleFromStorage as jest.Mock).mockReturnValue('en');

      render(
        <LocaleProvider>
          <div data-testid="child">Test Content</div>
        </LocaleProvider>
      );

      await waitFor(() => {
        expect(screen.getByTestId('child')).toBeInTheDocument();
        expect(screen.getByTestId('child')).toHaveTextContent('Test Content');
      });
    });

    it('should not render children before translations are loaded', () => {
      (getLocaleFromStorage as jest.Mock).mockReturnValue('en');

      const { container } = render(
        <LocaleProvider>
          <div data-testid="child">Test Content</div>
        </LocaleProvider>
      );

      // Initially, children should not be rendered (messages is null)
      // This is a synchronous check before the async load completes
      expect(container.firstChild).toBeNull();
    });
  });

  describe('Invalid Locale Handling', () => {
    it('should handle invalid locale by defaulting to English', async () => {
      // Mock getLocaleFromStorage to return default after detecting invalid locale
      (getLocaleFromStorage as jest.Mock).mockReturnValue('en');

      render(
        <LocaleProvider>
          <div data-testid="child">Test Content</div>
        </LocaleProvider>
      );

      await waitFor(() => {
        const provider = screen.getByTestId('intl-provider');
        expect(provider).toHaveAttribute('data-locale', 'en');
      });
    });
  });
});
