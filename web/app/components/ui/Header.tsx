"use client";

import React from "react";
import { 
  ChevronDown, 
  Wifi, 
  CalendarDays, 
  Bell, 
} from "lucide-react";

export default function Header() {
  return (
    <header className="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-4 sm:px-6 z-10 sticky top-0">
      
      {/* Store Selection */}
      <div className="flex items-center gap-4">
        <button className="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 hover:border-slate-300 transition-all group">
          <span className="text-sm font-medium text-slate-700 group-hover:text-indigo-600">
            Merkato Mini-Market
          </span>
          <ChevronDown size={16} className="text-slate-400 group-hover:text-indigo-600" />
        </button>

        {/* online status  */}
        <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-emerald-50 border border-emerald-100 text-xs font-medium text-emerald-600">
          <Wifi size={12} />
          <span>Online</span>
        </div>
      </div>

      {/* right section */}
      <div className="flex items-center gap-2 sm:gap-4">
        
        {/* date */}
        <div className="hidden md:flex items-center gap-2 text-sm text-slate-500 bg-slate-50 px-3 py-1.5 rounded-md border border-slate-100">
          <CalendarDays size={16} className="text-slate-400" />
          <span>Fri, Feb 20 2026</span>
        </div>

        <div className="h-6 w-px bg-slate-200 hidden sm:block"></div>

        {/* notification bell */}
        <button className="relative p-2 rounded-lg text-slate-400 hover:bg-indigo-50 hover:text-indigo-600 transition-all">
          <Bell size={20} />
          
          <span className="absolute top-2 right-2.5 h-2 w-2 rounded-full bg-red-500 ring-2 ring-white"></span>
        </button>

        {/* profile */}
        <button className="flex items-center gap-2 ml-1">
          <div className="h-9 w-9 rounded-full bg-indigo-100 border border-indigo-200 flex items-center justify-center text-indigo-700 font-bold text-xs shadow-sm hover:ring-2 hover:ring-indigo-100 transition-all">
            AT
          </div>
          <div className="hidden lg:flex flex-col items-start">
            <span className="text-sm font-medium text-slate-700">James</span>
            <span className="text-[10px] text-slate-500 uppercase tracking-wide">Manager</span>
          </div>
        </button>
      </div>
    </header>
  );
}