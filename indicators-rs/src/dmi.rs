/// Directional Movement Index
///
/// Formula taken from:
/// https://www.investopedia.com/terms/a/adx.asp
/// https://corporatefinanceinstitute.com/resources/equities/directional-movement-index-dmi/

use crate::ma::MA;

pub struct DMI {
    period: usize,
    previous_high: f64,
    previous_low: f64,
    previous_close: f64,
    smoothed_dm_pos: MA,
    smoothed_dm_neg: MA,
    smoothed_tr: MA,
    di_pos: MA,
    di_neg: MA,
    adx: MA,
    len: usize,
}

pub struct DMIValue {
    pub di_pos: f64,
    pub di_neg: f64,
    pub adx: f64,
}

impl DMI {
    
    pub fn new(period: usize) -> Self {
        DMI {
            period,
            previous_high: 0.0,
            previous_low: 0.0,
            previous_close: 0.0,
            smoothed_dm_pos: MA::new(period),
            smoothed_dm_neg: MA::new(period),
            smoothed_tr: MA::new(period),
            di_pos: MA::new(period),
            di_neg: MA::new(period),
            adx: MA::new(period),
            len: 0,
        }
    }

    pub fn update(&mut self, low: f64, high: f64, close: f64) -> DMIValue {
        if self.len > 0 {
            let tr = (high - low).abs()
                .max((high - self.previous_close).abs())
                .max((low - self.previous_close).abs());
            let mut dm_pos = high - self.previous_high;
            let mut dm_neg = self.previous_low - low;
            if dm_pos > dm_neg {
                dm_neg = 0.0;
            } else if dm_neg > dm_pos {
                dm_pos = 0.0;
            }
            self.smoothed_dm_pos.update(dm_pos);
            self.smoothed_dm_neg.update(dm_neg);
            self.smoothed_tr.update(tr);
        }
        if self.len > self.period + 1 {
            let di_pos = self.smoothed_dm_pos.get() / self.smoothed_tr.get();
            let di_neg = self.smoothed_dm_neg.get() / self.smoothed_tr.get();
            let dx = (di_pos - di_neg) / (di_pos + di_neg);
            self.di_pos.update(di_pos);
            self.di_neg.update(di_neg);
            self.adx.update(dx);
        }
        self.previous_close = close;
        self.previous_low = low;
        self.previous_high = high;
        self.len += 1;
        return self.get()
    }

    pub fn get(&self) -> DMIValue {
        if self.len >= self.period * 2 + 1 {
            DMIValue {
                di_pos: self.di_pos.get(),
                di_neg: self.di_neg.get(),
                adx: self.adx.get(),
            }
        } else {
            DMIValue {
                di_pos: std::f64::NAN,
                di_neg: std::f64::NAN,
                adx: std::f64::NAN,
            }
        }
    }
}
