pub struct MA {
    periods: usize,
    accum: f64,
    window: Vec<f64>,
    pos: usize,
    len: usize,
}

impl MA {
    pub fn new(periods: usize) -> Self {
        Self {
            periods,
            accum: 0.0,
            window: vec![0.0; periods],
            pos: 0,
            len: 0,
        }
    }
    pub fn update(&mut self, value: f64) -> f64 {
        if self.len < self.periods {
            self.len += 1;
        } else {
            self.accum -= self.window[self.pos];
        }
        self.accum += value;
        self.window[self.pos] = value;
        self.pos = (self.pos + 1) % self.periods;
        self.get()
    }
    pub fn get(&self) -> f64 {
        if self.len < self.periods {
            std::f64::NAN
        } else {
            self.accum / self.len as f64
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_ma() {
        let mut ma = MA::new(3);
        let ts: Vec<f64> = vec![1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
        for value in ts.iter() {
            let y = ma.update(*value);
            if *value < 3.0 {
                assert!(y.is_nan());
            } else {
                assert_eq!(y, value - 1.0);
            }
        }
    }
}
