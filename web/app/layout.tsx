import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import ThemeProvider from "./components/providers/ThemeProvider";
import LocaleProvider from "./components/providers/LocaleProvider";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Shop Ops",
  description: "Shop Management System",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable}  flex bg-background text-foreground`}
      >
        <ThemeProvider>
          <LocaleProvider>
            <main className="flex-1">{children}</main>
          </LocaleProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}