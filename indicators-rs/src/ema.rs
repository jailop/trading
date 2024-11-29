pub struct EMA {
    periods: usize,
    smooth_factor: f64,
    len: usize,
    prev: f64,
}

impl EMA {
    pub fn new(periods: usize, alpha: f64) -> Self {
        let smooth_factor = alpha / (1.0 + periods as f64);
        EMA {
            periods,
            smooth_factor,
            len: 0,
            prev: 0.0,
        }
    }

    pub fn update(&mut self, value: f64) -> f64 {
        self.len += 1;
        if self.len < self.periods {
            self.prev += value;
        } else if self.len == self.periods {
            self.prev += value;
            // Initial average
            self.prev /= 1.0 * self.periods as f64;
        } else {
            self.prev = (value * self.smooth_factor)
                + (self.prev * (1.0 - self.smooth_factor));
        }
        self.get()
    }

    pub fn get(&self) -> f64 {
        if self.len >= self.periods {
            self.prev
        } else {
            std::f64::NAN
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_ema() {
        let periods: usize = 5;
        let mut ema = EMA::new(periods, 2.0);
        let ts: Vec<f64> = vec![10.0, 12.0, 14.0, 13.0, 15.0, 16.0, 18.0];
        let res: Vec<f64> = vec![12.8, 13.866666, 15.244444];
        for i in 0..ts.len() {
            let y = ema.update(ts[i]);
            if i < periods - 1 {
                assert!(y.is_nan());
            } else {
                assert!((y - res[i + 1 - periods]).abs() < 1e-6);
            }
        }
    }
}
