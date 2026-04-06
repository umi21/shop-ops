# Guided Tour Feature

## Overview
The guided tour feature provides an interactive walkthrough of the system for new users when they first sign up and log in. It highlights key features and helps users understand how to navigate and use the application.

## Components

### 1. GuidedTour Component (`web/app/components/ui/GuidedTour.tsx`)
The main tour component that displays:
- An overlay to focus attention on the current step
- A highlight ring around the target element
- A tooltip with step information
- Navigation controls (Previous, Next, Finish)
- A close button to skip the tour

### 2. useTour Hook (`web/app/hooks/useTour.ts`)
A custom React hook that manages tour state:
- `showTour`: Boolean indicating if the tour should be displayed
- `completeTour()`: Marks the tour as completed
- `skipTour()`: Allows users to skip the tour
- `resetTour()`: Restarts the tour (useful for replaying)

The hook uses localStorage to persist tour completion status:
- `tour_completed`: Set when user completes the tour
- `tour_skipped`: Set when user skips the tour

### 3. Tour Steps Configuration (`web/app/config/tourSteps.ts`)
Defines the tour steps with:
- `target`: CSS selector for the element to highlight
- `title`: Step title
- `content`: Step description
- `position`: Tooltip position (top, bottom, left, right)

## Tour Steps

1. **Business Switcher**: Introduction to managing multiple businesses
2. **Inventory Management**: Overview of product tracking
3. **Sales Tracking**: How to record and view sales
4. **Expense Management**: Managing business expenses
5. **Reports & Analytics**: Accessing business reports
6. **Quick Stats**: Understanding dashboard metrics
7. **Stock Alerts**: Low stock notifications
8. **Profile Menu**: Account settings and logout

## Integration

### Dashboard Layout
The tour is integrated into the dashboard layout (`web/app/dashboard/layout.tsx`):
```tsx
import GuidedTour from "../components/ui/GuidedTour";
import { useTour } from "../hooks/useTour";
import { dashboardTourSteps } from "../config/tourSteps";

const { showTour, completeTour, skipTour } = useTour();

{showTour && (
  <GuidedTour
    steps={dashboardTourSteps}
    onComplete={completeTour}
    onSkip={skipTour}
  />
)}
```

### Data Attributes
Tour targets are marked with `data-tour` attributes:
- `data-tour="business-switcher"` - Business switcher component
- `data-tour="sidebar-inventory"` - Inventory navigation link
- `data-tour="sidebar-sales"` - Sales navigation link
- `data-tour="sidebar-expenses"` - Expenses navigation link
- `data-tour="sidebar-reports"` - Reports navigation link
- `data-tour="stats-card"` - Dashboard stats cards
- `data-tour="stock-alerts"` - Stock alerts section
- `data-tour="profile-menu"` - Profile menu link

## User Experience

### First Time Users
- Tour automatically starts 1 second after the dashboard loads
- Users can navigate through steps using Next/Previous buttons
- Users can skip the tour at any time using the X button
- Tour completion is saved to localStorage

### Returning Users
- Tour does not show if already completed or skipped
- Users can restart the tour from the Profile page
- "Restart Tour" button available in the profile header

## Customization

### Adding New Steps
To add new tour steps, edit `web/app/config/tourSteps.ts`:
```tsx
{
  target: "[data-tour='your-element']",
  title: "Step Title",
  content: "Step description",
  position: "bottom",
}
```

### Styling
The tour uses Tailwind CSS classes and can be customized in:
- `GuidedTour.tsx` - Main component styling
- Overlay: `bg-black/60`
- Highlight ring: `ring-4 ring-indigo-500`
- Tooltip: `bg-white border border-slate-200 shadow-2xl`

### Positioning
The tooltip automatically positions itself based on the target element's location and the specified position parameter. The component handles scrolling to ensure the target element is visible.

## Browser Compatibility
- Uses modern JavaScript features (localStorage, querySelector)
- Requires CSS Grid and Flexbox support
- Tested on Chrome, Firefox, Safari, and Edge

## Future Enhancements
- Add support for interactive elements within tour steps
- Implement conditional steps based on user actions
- Add progress indicators
- Support for multiple tour sequences
- Analytics tracking for tour completion rates
