"use client";

import React, { useEffect, useState } from "react";
import { X, ChevronLeft, ChevronRight } from "lucide-react";

type TourStep = {
  target: string;
  title: string;
  content: string;
  position?: "top" | "bottom" | "left" | "right";
  allowInteraction?: boolean;
};

type GuidedTourProps = {
  steps: TourStep[];
  onComplete: () => void;
  onSkip: () => void;
  allowNavigation?: boolean;
};

const GuidedTour: React.FC<GuidedTourProps> = ({ 
  steps, 
  onComplete, 
  onSkip,
  allowNavigation = true 
}) => {
  const [currentStep, setCurrentStep] = useState(0);
  const [targetElement, setTargetElement] = useState<HTMLElement | null>(null);
  const [tooltipPosition, setTooltipPosition] = useState({ top: 0, left: 0 });

  useEffect(() => {
    const element = document.querySelector(steps[currentStep].target) as HTMLElement;
    setTargetElement(element);

    if (element) {
      element.scrollIntoView({ behavior: "smooth", block: "center" });
      
      const rect = element.getBoundingClientRect();
      const position = steps[currentStep].position || "bottom";
      
      const tooltipWidth = 320; // 80 * 4 (w-80 in pixels)
      const tooltipHalfWidth = tooltipWidth / 2;
      const viewportWidth = window.innerWidth;
      const viewportHeight = window.innerHeight;
      
      let top = 0;
      let left = 0;

      switch (position) {
        case "top":
          top = rect.top - 20;
          left = rect.left + rect.width / 2;
          break;
        case "bottom":
          top = rect.bottom + 20;
          left = rect.left + rect.width / 2;
          break;
        case "left":
          top = rect.top + rect.height / 2;
          left = rect.left - 20;
          break;
        case "right":
          top = rect.top + rect.height / 2;
          left = rect.right + 20;
          break;
      }

      // Prevent horizontal overflow
      if (left - tooltipHalfWidth < 16) {
        left = tooltipHalfWidth + 16;
      } else if (left + tooltipHalfWidth > viewportWidth - 16) {
        left = viewportWidth - tooltipHalfWidth - 16;
      }

      // Prevent vertical overflow
      if (top < 16) {
        top = 16;
      } else if (top > viewportHeight - 200) {
        top = viewportHeight - 200;
      }

      setTooltipPosition({ top, left });
    }
  }, [currentStep, steps]);

  const handleNext = () => {
    if (currentStep < steps.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      onComplete();
    }
  };

  const handlePrevious = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  };

  const currentStepData = steps[currentStep];
  const allowInteraction = currentStepData.allowInteraction || false;

  return (
    <>
      {/* Overlay - allow clicks if interaction is enabled */}
      <div 
        className="fixed inset-0 z-[100] bg-black/60" 
        onClick={allowNavigation ? undefined : onSkip}
        style={{ pointerEvents: allowInteraction ? 'none' : 'auto' }}
      />

      {/* Highlight */}
      {targetElement && (
        <div
          className="fixed z-[101] rounded-lg ring-4 ring-indigo-500 ring-offset-2"
          style={{
            top: targetElement.getBoundingClientRect().top - 4,
            left: targetElement.getBoundingClientRect().left - 4,
            width: targetElement.getBoundingClientRect().width + 8,
            height: targetElement.getBoundingClientRect().height + 8,
            pointerEvents: allowInteraction ? 'none' : 'auto',
          }}
        />
      )}

      {/* Tooltip */}
      <div
        className="fixed z-[102] w-80 max-w-[calc(100vw-2rem)] rounded-xl border border-slate-200 bg-white p-5 shadow-2xl"
        style={{
          top: tooltipPosition.top,
          left: tooltipPosition.left,
          transform: "translate(-50%, 0)",
        }}
      >
        <button
          onClick={onSkip}
          className="absolute right-3 top-3 rounded-full p-1 text-slate-400 transition hover:bg-slate-100 hover:text-slate-600"
        >
          <X className="h-4 w-4" />
        </button>

        <div className="mb-3">
          <h3 className="text-lg font-semibold text-slate-900">{currentStepData.title}</h3>
          <p className="mt-1 text-sm text-slate-600">{currentStepData.content}</p>
        </div>

        <div className="flex items-center justify-between">
          <span className="text-xs text-slate-500">
            Step {currentStep + 1} of {steps.length}
          </span>

          <div className="flex gap-2">
            {currentStep > 0 && (
              <button
                onClick={handlePrevious}
                className="flex items-center gap-1 rounded-full border border-slate-200 px-3 py-1.5 text-sm font-medium text-slate-700 transition hover:bg-slate-50"
              >
                <ChevronLeft className="h-4 w-4" />
                Back
              </button>
            )}
            <button
              onClick={handleNext}
              className="flex items-center gap-1 rounded-full bg-indigo-600 px-4 py-1.5 text-sm font-medium text-white transition hover:bg-indigo-700"
            >
              {currentStep < steps.length - 1 ? (
                <>
                  Next
                  <ChevronRight className="h-4 w-4" />
                </>
              ) : (
                "Finish"
              )}
            </button>
          </div>
        </div>
      </div>
    </>
  );
};

export default GuidedTour;
