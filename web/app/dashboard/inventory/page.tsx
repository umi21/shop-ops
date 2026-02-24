import React from 'react'
import PageTitle from '@/app/components/ui/PageTitle'
import Card from '@/app/components/ui/Card'
import { DollarSign, TrendingUp } from 'lucide-react'

const Inventory = () => {
  return (
    <div className='flex flex-col space-y-4'>
      <PageTitle
        title="Inventory"
        subtitle="Manage your product stock levels"
      />

      <div className='grid gap-4 lg:grid-cols-3'>
        <Card
          title=""
          value="5"
          icon={TrendingUp}
          iconWrapperClass="bg-red-50 text-red-600"
          trend=""
          trendDirection=""
          description="In Stock"
        />

        <Card
          title=""
          value="3"
          icon={DollarSign}
          iconWrapperClass="bg-indigo-50 text-indigo-600"
          trend=""
          trendDirection=""
          description="Low Stock"
        />

        

        <Card
          title=""
          value="3"
          icon={DollarSign}
          iconWrapperClass="bg-indigo-50 text-indigo-600"
          trend=""
          trendDirection=""
          description="Out of Stock"
        />


      </div>



    </div>
  )
}

export default Inventory