"use client";
import Card from "../components/ui/Card";
import SalesVsExpensesChart, {
    ChartDataPoint,
} from "../components/charts/SalesVsExpensesChart";
import PageTitle from "../components/ui/PageTitle";
import React, { useEffect, useMemo, useState } from "react";
import StockAlertList from "../components/ui/StockAlertList";
import { DollarSign, TrendingUp, Package, TriangleAlert } from "lucide-react";
import { fetchSalesStats, fetchSalesSummary, formatSalesMoney } from "@/lib/sales";
import { fetchExpenseSummary, formatMoney, toAmountNumber } from "@/lib/expenses";

type ActiveBusiness = {
    id: string;
};

const formatDateForApi = (date: Date) => {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const day = String(date.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
};

const readActiveBusinessId = () => {
    if (typeof window === "undefined") {
        return "";
    }

    try {
        const raw = window.localStorage.getItem("activeBusiness");
        if (!raw) {
            return "";
        }

        const parsed = JSON.parse(raw) as ActiveBusiness;
        return parsed?.id ?? "";
    } catch {
        return "";
    }
};

export default function DashboardPage() {
        const [activeBusinessId, setActiveBusinessId] = useState("");
        const [isLoading, setIsLoading] = useState(false);
        const [todaySales, setTodaySales] = useState(0);
        const [todaySalesCount, setTodaySalesCount] = useState(0);
        const [monthlySales, setMonthlySales] = useState(0);
        const [todayExpenses, setTodayExpenses] = useState(0);
        const [pendingSyncs, setPendingSyncs] = useState(0);

        useEffect(() => {
                const syncActiveBusiness = () => {
                        setActiveBusinessId(readActiveBusinessId());
                };

                syncActiveBusiness();
                window.addEventListener("activeBusinessChanged", syncActiveBusiness);

                return () => {
                        window.removeEventListener("activeBusinessChanged", syncActiveBusiness);
                };
        }, []);

        useEffect(() => {
                const loadDashboardMetrics = async () => {
                        if (!activeBusinessId) {
                                setTodaySales(0);
                                setTodaySalesCount(0);
                                setMonthlySales(0);
                                setTodayExpenses(0);
                                setPendingSyncs(0);
                                return;
                        }

                        const now = new Date();
                        const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
                        const today = formatDateForApi(now);

                        setIsLoading(true);

                        try {
                                const [salesStats, monthSummary, expenseSummary] = await Promise.all([
                                        fetchSalesStats(activeBusinessId),
                                        fetchSalesSummary(activeBusinessId, formatDateForApi(monthStart), today),
                                        fetchExpenseSummary(activeBusinessId, today, today),
                                ]);

                                setTodaySales(salesStats.daily.total_revenue ?? 0);
                                setTodaySalesCount(salesStats.daily.total_sales ?? 0);
                                setMonthlySales(monthSummary.total_revenue ?? 0);
                                setTodayExpenses(toAmountNumber(expenseSummary.total ?? 0));
                                setPendingSyncs(salesStats.daily.voided_count ?? 0);
                        } catch {
                                setTodaySales(0);
                                setTodaySalesCount(0);
                                setMonthlySales(0);
                                setTodayExpenses(0);
                                setPendingSyncs(0);
                        } finally {
                                setIsLoading(false);
                        }
                };

                loadDashboardMetrics();
        }, [activeBusinessId]);

        const chartData = useMemo<ChartDataPoint[]>(() => {
                const baseSales = monthlySales > 0 ? monthlySales : 1;
                const baseExpenses = todayExpenses > 0 ? todayExpenses : 1;

                return [
                        { name: "Week 1", sales: baseSales * 0.15, expenses: baseExpenses * 4.2 },
                        { name: "Week 2", sales: baseSales * 0.22, expenses: baseExpenses * 5.1 },
                        { name: "Week 3", sales: baseSales * 0.28, expenses: baseExpenses * 5.8 },
                        { name: "Week 4", sales: baseSales * 0.35, expenses: baseExpenses * 6.4 },
                ].map((item) => ({
                        ...item,
                        sales: Number(item.sales.toFixed(2)),
                        expenses: Number(item.expenses.toFixed(2)),
                }));
        }, [monthlySales, todayExpenses]);

    return (
        <div className="flex flex-col space-y-4">
            {/* Dashboard Header */}
            <PageTitle
                title="Dashboard"
                subtitle="Overview of your business operations"
            />

            {/* Dashboard KPI Cards */}
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                <Card
                    title="Today's Sales"
                    value={isLoading ? "Loading..." : formatSalesMoney(todaySales)}
                    icon={DollarSign}
                    iconWrapperClass="bg-indigo-50 text-indigo-600"
                    trend=""
                    trendDirection="up"
                    description={`${todaySalesCount} transactions today`}
                />

                <Card
                    title="Today's Expenses"
                    value={isLoading ? "Loading..." : formatMoney(todayExpenses)}
                    icon={TrendingUp}
                    iconWrapperClass="bg-red-50 text-red-600"
                    trend=""
                    trendDirection="down"
                    description="Based on recorded expenses"
                />

                <Card
                    title="Monthly Sales"
                    value={isLoading ? "Loading..." : formatSalesMoney(monthlySales)}
                    icon={DollarSign}
                    iconWrapperClass="bg-indigo-50 text-indigo-600"
                    trend=""
                    trendDirection="up"
                    description="Current month cumulative"
                />

                <Card
                    title="Pending Syncs"
                    value={String(pendingSyncs)}
                    icon={Package}
                    iconWrapperClass="bg-orange-50 text-orange-600"
                    description="Voided sales today"
                    trend=""
                />
            </div>

            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7 ">
                {/* Chart */}
                <SalesVsExpensesChart data={chartData} className="col-span-4" />

                {/* Low Stock Alerts */}
                <div className="col-span-3 rounded-xl border border-slate-200 bg-white shadow-sm">
                    <div className="p-6 flex flex-col space-y-1.5">
                        <h3 className="font-semibold leading-none tracking-tight flex items-center gap-2">
                            <TriangleAlert className="h-4 w-4 text-amber-500" />
                            Low Stock Alerts
                        </h3>
                        <p className="text-sm text-slate-500">5 items require attention</p>
                    </div>
                    <div className="p-6 pt-0">
                        <StockAlertList />
                    </div>
                </div>
            </div>
        </div>
    );
}