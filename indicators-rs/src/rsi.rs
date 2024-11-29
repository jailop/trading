use crate::ma::MA;

pub struct RSI {
    gains: MA,
    losses: MA,
}

impl RSI {
    pub fn new(period: usize) -> RSI {
        RSI {
            gains: MA::new(period),
            losses: MA::new(period),
        }
    }

    pub fn update(&mut self, open_price: f64, close_price: f64) -> f64 {
        let diff = close_price - open_price;
        self.gains.update(if diff >= 0.0 { diff } else { 0.0 });
        self.losses.update(if diff < 0.0 { -diff } else { 0.0 });
        self.get()
    }

    pub fn get(&self) -> f64 {
        if self.losses.get().is_nan() {
            std::f64::NAN
        } else {
            100.0 - 100.0 / (1.0 + self.gains.get() / self.losses.get())
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_rsi() {
        let mut rsi = RSI::new(3);
        rsi.update(1.0, 2.0);
        assert!(rsi.get().is_nan());
        rsi.update(2.0, 4.0);
        assert!(rsi.get().is_nan());
        rsi.update(4.0, 3.0);
        assert!((rsi.get() - 75.0).abs() < 1e-6);
    }
}
