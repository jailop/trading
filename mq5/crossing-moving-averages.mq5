//+------------------------------------------------------------------+
//|                                   Crossing Moving Averages.mq5   |
//|                                  Copyright 2025, Jaime Lopez      |
//|                                  https://github.com/jailop/       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Jaime Lopez"
#property link      "https://github.com/jailop/"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

//--- Plot Fast MA
#property indicator_label1  "Fast MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Plot Slow MA
#property indicator_label2  "Slow MA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Plot Buy Signal
#property indicator_label3  "Buy"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrGreen
#property indicator_width3  3

//--- Plot Sell Signal
#property indicator_label4  "Sell"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  3

//--- Input parameters
input int      InpFastPeriod = 9;        // Fast Moving Average Period
input int      InpSlowPeriod = 21;       // Slow Moving Average Period
input ENUM_MA_METHOD InpMAType = MODE_EMA; // Moving Average Type

//--- Indicator buffers
double FastMABuffer[];
double SlowMABuffer[];
double BuySignalBuffer[];
double SellSignalBuffer[];

//--- Handles for moving averages
int fastMA_handle;
int slowMA_handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Indicator buffers mapping
   SetIndexBuffer(0, FastMABuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SlowMABuffer, INDICATOR_DATA);
   SetIndexBuffer(2, BuySignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, SellSignalBuffer, INDICATOR_DATA);
   
   //--- Set arrow codes
   PlotIndexSetInteger(2, PLOT_ARROW, 233);  // Up arrow for buy
   PlotIndexSetInteger(3, PLOT_ARROW, 234);  // Down arrow for sell
   
   //--- Set empty value
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);
   
   //--- Create moving average handles
   fastMA_handle = iMA(_Symbol, _Period, InpFastPeriod, 0, InpMAType, PRICE_CLOSE);
   slowMA_handle = iMA(_Symbol, _Period, InpSlowPeriod, 0, InpMAType, PRICE_CLOSE);
   
   if(fastMA_handle == INVALID_HANDLE || slowMA_handle == INVALID_HANDLE)
   {
      Print("Error creating MA handles");
      return(INIT_FAILED);
   }
   
   //--- Set indicator short name
   string ma_type_str;
   switch(InpMAType)
   {
      case MODE_SMA:  ma_type_str = "SMA"; break;
      case MODE_EMA:  ma_type_str = "EMA"; break;
      case MODE_SMMA: ma_type_str = "SMMA"; break;
      case MODE_LWMA: ma_type_str = "LWMA"; break;
      default:        ma_type_str = "MA"; break;
   }
   
   string short_name = StringFormat("Crossing Moving Averages (%s %d/%d)", 
                                     ma_type_str, InpFastPeriod, InpSlowPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release indicator handles
   if(fastMA_handle != INVALID_HANDLE)
      IndicatorRelease(fastMA_handle);
   if(slowMA_handle != INVALID_HANDLE)
      IndicatorRelease(slowMA_handle);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //--- Check if we have enough bars
   if(rates_total < InpSlowPeriod)
      return(0);
   
   //--- Determine the number of bars to calculate
   int limit;
   if(prev_calculated == 0)
      limit = InpSlowPeriod;  // Start from the slow period
   else
      limit = prev_calculated - 1;
   
   //--- Copy MA values
   if(CopyBuffer(fastMA_handle, 0, 0, rates_total, FastMABuffer) <= 0)
   {
      Print("Error copying Fast MA buffer");
      return(0);
   }
   
   if(CopyBuffer(slowMA_handle, 0, 0, rates_total, SlowMABuffer) <= 0)
   {
      Print("Error copying Slow MA buffer");
      return(0);
   }
   
   //--- Main calculation loop
   for(int i = limit; i < rates_total; i++)
   {
      //--- Initialize signal buffers
      BuySignalBuffer[i] = 0.0;
      SellSignalBuffer[i] = 0.0;
      
      //--- Check for crossover (buy signal)
      if(i > 0)
      {
         // Crossover: Fast MA crosses above Slow MA
         if(FastMABuffer[i] > SlowMABuffer[i] && 
            FastMABuffer[i-1] <= SlowMABuffer[i-1])
         {
            BuySignalBuffer[i] = low[i];
         }
         
         // Crossunder: Fast MA crosses below Slow MA
         if(FastMABuffer[i] < SlowMABuffer[i] && 
            FastMABuffer[i-1] >= SlowMABuffer[i-1])
         {
            SellSignalBuffer[i] = high[i];
         }
      }
   }
   
   //--- Return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
