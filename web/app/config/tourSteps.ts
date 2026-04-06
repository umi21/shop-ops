export const dashboardTourSteps = [
  {
    target: "[data-tour='business-switcher']",
    title: "Welcome to Your Dashboard!",
    content: "Let's take a quick tour. First, this is your Business Switcher. You can create and switch between multiple businesses here.",
    position: "bottom" as const,
  },
  {
    target: "[data-tour='stats-card']",
    title: "Quick Stats",
    content: "View your key business metrics at a glance. These cards show real-time data about your business.",
    position: "bottom" as const,
  },
  {
    target: "[data-tour='stock-alerts']",
    title: "Stock Alerts",
    content: "Get notified when products are running low so you can restock in time.",
    position: "top" as const,
  },
  {
    target: "[data-tour='sidebar-inventory']",
    title: "Inventory Management",
    content: "Click here to track your products, stock levels, and get alerts when items are running low. Let's explore it!",
    position: "right" as const,
    allowInteraction: true,
  },
];

export const inventoryTourSteps = [
  {
    target: "[data-tour='add-product-btn']",
    title: "Add Products",
    content: "Click here to add new products to your inventory. You can set prices, stock levels, and track quantities.",
    position: "bottom" as const,
  },
  {
    target: "[data-tour='product-filters']",
    title: "Filter Products",
    content: "Use these filters to search and organize your products by category, stock status, or name.",
    position: "bottom" as const,
  },
  {
    target: "[data-tour='product-table']",
    title: "Product List",
    content: "View all your products here. You can edit, delete, or update stock levels directly from this table.",
    position: "top" as const,
  },
  {
    target: "[data-tour='sidebar-sales']",
    title: "Next: Sales Tracking",
    content: "Now let's check out the Sales section to see how you can record and track your sales.",
    position: "right" as const,
    allowInteraction: true,
  },
];

export const salesTourSteps = [
  {
    target: "[data-tour='record-sale-btn']",
    title: "Record Sales",
    content: "Click here to record a new sale. You can link products, set quantities, and add notes.",
    position: "bottom" as const,
  },
  {
    target: "[data-tour='sales-stats']",
    title: "Sales Metrics",
    content: "Track today's sales, average sale value, and total transactions in the selected period.",
    position: "bottom" as const,
  },
  {
    target: "[data-tour='sales-filters']",
    title: "Filter Sales",
    content: "Filter sales by time range and search by product ID, note, or status.",
    position: "bottom" as const,
  },
  {
    target: "[data-tour='sales-table']",
    title: "Sales History",
    content: "View all your sales transactions. You can view details, edit notes, or void sales if needed.",
    position: "top" as const,
  },
  {
    target: "[data-tour='sidebar-expenses']",
    title: "Next: Expense Management",
    content: "Let's explore how to track your business expenses.",
    position: "right" as const,
    allowInteraction: true,
  },
];

export const expensesTourSteps = [
  {
    target: "[data-tour='add-expense-btn']",
    title: "Add Expenses",
    content: "Record your business expenses here. Categorize them for better tracking and reporting.",
    position: "bottom" as const,
  },
  {
    target: "[data-tour='expense-stats']",
    title: "Expense Overview",
    content: "Monitor your total expenses, daily spending, and expense breakdown by category.",
    position: "bottom" as const,
  },
  {
    target: "[data-tour='expense-charts']",
    title: "Expense Analytics",
    content: "Visualize your expenses with charts showing trends and category breakdowns.",
    position: "top" as const,
  },
  {
    target: "[data-tour='sidebar-reports']",
    title: "Next: Reports",
    content: "Finally, let's see how to generate comprehensive business reports.",
    position: "right" as const,
    allowInteraction: true,
  },
];

export const reportsTourSteps = [
  {
    target: "[data-tour='report-filters']",
    title: "Report Filters",
    content: "Select date ranges and report types to generate custom reports for your business.",
    position: "bottom" as const,
  },
  {
    target: "[data-tour='generate-report-btn']",
    title: "Generate Reports",
    content: "Click here to generate detailed reports. You can export them for record-keeping.",
    position: "bottom" as const,
  },
  {
    target: "[data-tour='report-summary']",
    title: "Report Summary",
    content: "View comprehensive summaries of your sales, expenses, and profit margins.",
    position: "top" as const,
  },
  {
    target: "[data-tour='profile-menu']",
    title: "Tour Complete!",
    content: "Great job! You can access your profile settings here. You can restart this tour anytime from your profile page.",
    position: "bottom" as const,
  },
];
