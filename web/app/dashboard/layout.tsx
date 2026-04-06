"use client";

import React from "react";
import Sidebar from "../components/ui/Sidebar";
import Header from "../components/ui/Header";
import GuidedTour from "../components/ui/GuidedTour";
import { useTour } from "../hooks/useTour";
import { dashboardTourSteps } from "../config/tourSteps";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { showTour, completeTour, skipTour } = useTour();

  return (
    <div className="flex h-full w-full h-screen">
      <Sidebar />
      <div className="flex flex-col flex-1">
        <Header />
        <div className="flex flex-col flex-1 overflow-y-auto overflow-x-hidden gap-4 p-4 md:gap-8 md:p-6 bg-slate-50">
          {children}
        </div>
      </div>

      {showTour && (
        <GuidedTour
          steps={dashboardTourSteps}
          onComplete={completeTour}
          onSkip={skipTour}
        />
      )}
    </div>
  );
}
