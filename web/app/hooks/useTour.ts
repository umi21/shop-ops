"use client";

import { useEffect, useState } from "react";

const TOUR_COMPLETED_KEY = "tour_completed";
const TOUR_SKIPPED_KEY = "tour_skipped";
const PAGE_TOURS_COMPLETED_KEY = "page_tours_completed";

export const useTour = (pageName?: string) => {
  const [showTour, setShowTour] = useState(false);

  useEffect(() => {
    if (typeof window === "undefined") return;

    const tourCompleted = localStorage.getItem(TOUR_COMPLETED_KEY);
    const tourSkipped = localStorage.getItem(TOUR_SKIPPED_KEY);

    // For page-specific tours
    if (pageName) {
      const completedPages = JSON.parse(
        localStorage.getItem(PAGE_TOURS_COMPLETED_KEY) || "[]"
      );
      
      // Show page tour if main tour is completed/skipped but this page hasn't been toured
      if ((tourCompleted || tourSkipped) && !completedPages.includes(pageName)) {
        const timer = setTimeout(() => {
          setShowTour(true);
        }, 500);
        return () => clearTimeout(timer);
      }
    } else {
      // Main dashboard tour
      if (!tourCompleted && !tourSkipped) {
        const timer = setTimeout(() => {
          setShowTour(true);
        }, 1000);
        return () => clearTimeout(timer);
      }
    }
  }, [pageName]);

  const completeTour = () => {
    if (pageName) {
      const completedPages = JSON.parse(
        localStorage.getItem(PAGE_TOURS_COMPLETED_KEY) || "[]"
      );
      if (!completedPages.includes(pageName)) {
        completedPages.push(pageName);
        localStorage.setItem(PAGE_TOURS_COMPLETED_KEY, JSON.stringify(completedPages));
      }
    } else {
      localStorage.setItem(TOUR_COMPLETED_KEY, "true");
    }
    setShowTour(false);
  };

  const skipTour = () => {
    if (pageName) {
      const completedPages = JSON.parse(
        localStorage.getItem(PAGE_TOURS_COMPLETED_KEY) || "[]"
      );
      if (!completedPages.includes(pageName)) {
        completedPages.push(pageName);
        localStorage.setItem(PAGE_TOURS_COMPLETED_KEY, JSON.stringify(completedPages));
      }
    } else {
      localStorage.setItem(TOUR_SKIPPED_KEY, "true");
    }
    setShowTour(false);
  };

  const resetTour = () => {
    localStorage.removeItem(TOUR_COMPLETED_KEY);
    localStorage.removeItem(TOUR_SKIPPED_KEY);
    localStorage.removeItem(PAGE_TOURS_COMPLETED_KEY);
    setShowTour(true);
  };

  return {
    showTour,
    completeTour,
    skipTour,
    resetTour,
  };
};
