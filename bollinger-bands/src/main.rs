use std::env;
use chrono::{DateTime, Utc};
use csv::Reader;
use std::error::Error;
use std::fs::File;

#[derive(Debug, Default)]
struct History {
    date: Vec<DateTime<Utc>>,
    open: Vec<f64>,
    high: Vec<f64>,
    low: Vec<f64>,
    close: Vec<f64>,
    volume: Vec<u64>,
}

impl History {
    fn read_csv(path: &str) -> Result<History, Box<dyn Error>> {
        let file = File::open(path)?;
        let mut reader = Reader::from_reader(file);
        let mut history = History::default();
        for item in reader.records() {
            let record = item?;
            let date = DateTime::parse_from_str(&record[0], "%Y-%m-%d %H:%M:%S%z")?
                .with_timezone(&Utc);
            history.date.push(date);
            history.open.push(record[1].parse()?);
            history.low.push(record[2].parse()?);
            history.high.push(record[3].parse()?);
            history.close.push(record[4].parse()?);
            history.volume.push(record[5].parse()?);
        }
        Ok(history)
    }
}

#[derive(Debug)]
struct StatQueue {
    buffer: Vec<f64>,
    capacity: usize,
    front: usize,
    rear: usize,
    size: usize,
    sum: f64,
}

impl StatQueue {
    fn new(capacity: usize) -> Self {
        StatQueue {
            buffer: vec![0.0; capacity],
            capacity,
            front: 0,
            rear: 0,
            size: 0,
            sum: 0.0,
        }
    }
    fn enqueue(&mut self, item: f64) {
        if self.size == self.capacity {
            panic!("Queue is full");
        }
        self.buffer[self.rear] = item;
        self.rear = (self.rear + 1) % self.capacity;
        self.size += 1;
        self.sum += item;
    }
    fn dequeue(&mut self) -> f64 {
        if self.size == 0 {
            panic!("Queue is empty");
        }
        let item = self.buffer[self.front];
        self.front = (self.front + 1) % self.capacity;
        self.size -= 1;
        self.sum -= item;
        item
    }
}

fn stddev(input: &Vec<f64>, period: usize) -> Vec<f64> {
    let mut res = Vec::new();
    let mut queue = StatQueue::new(period);
    for i in 0..period {
        res.push(f64::NAN);
        queue.enqueue(input[i]);
    }
    for i in period..input.len() {
        let mean = queue.sum / period as f64;
        let mut sum : f64 = 0.0;
        for j in 0..period {
            let diff = queue.buffer[j] - mean;
            sum += diff * diff;
        }
        let local_std = f64::sqrt(sum / period as f64);
        res.push(local_std);
        queue.dequeue();
        queue.enqueue(input[i]);
    }
    res
}

fn ema(input: &Vec<f64>, period: usize) -> Vec<f64> {
    let mut res = Vec::new();
    if input.is_empty() || period == 0 {
        return res;
    }
    let alpha = 2.0 / (period as f64 + 1.0);
    res.push(input[0]);
    for i in 1..input.len() {
        let ema = (input[i] * alpha) + (input[i - 1] * (1.0 - alpha));
        res.push(ema);
    }
    res
}

fn sum(a: &Vec<f64>, b: &Vec<f64>) -> Vec<f64> {
    let mut res = Vec::new();
    for i in 0..a.len() {
        res.push(a[i] + b[i]);
    }
    res
}

fn scale(a: &Vec<f64>, scalar: f64) -> Vec<f64> {
    let mut res = Vec::new();
    for i in 0..a.len() {
        res.push(a[i] * scalar);
    }
    res
}

#[derive(Debug, Clone)]
enum State {
    SuddenGap,
    Buy,
    Sell,
}

#[derive(Debug, Default)]
struct Actions {
    date: Vec<DateTime<Utc>>,
    price: Vec<f64>,
    action: Vec<State>,
}

impl Actions {
    fn roi(self) -> f64 {
        let mut r: f64 = 1.0;
        for i in 1..self.date.len() {
            match self.action[i] {
                State::Sell => {
                    let local_r = (self.price[i] - self.price[i - 1]) / self.price[i - 1];
                    r *= 1.0 + local_r;
                    println!("Buy  {}: {}", self.date[i - 1], self.price[i - 1]);
                    println!("Sell {}: {}", self.date[i], self.price[i]);
                    println!("Result: {} {}", local_r, r);
                    println!("");
                },
                _ => {},
            }
        }
        r
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = env::args().collect();
    let history = History::read_csv(&args[1])?;
    let res = ema(&history.close, 9);
    let factors = stddev(&res, 9);
    let upper_band = sum(&res, &scale(&factors, 2.0));
    let lower_band = sum(&res, &scale(&factors, -2.0));
    let mut state = State::Sell;
    let mut actions = Actions::default();
    for i in 0..res.len() {
        let diff = history.close[i] - history.open[i];
        let x = upper_band[i] - res[i];
        let y = res[i] - lower_band[i];
        match state {
            State::Sell => {
                if y > x {
                    state = State::SuddenGap;
                }
            },
            State::SuddenGap => {
                if diff > 0.0 && history.open[i] > res[i] {
                    state = State::Buy;
                    actions.date.push(history.date[i]);
                    actions.price.push(history.close[i]);
                    actions.action.push(state.clone());
                }        
            },
            State::Buy => {
                if diff < 0.0 && history.close[i] < res[i] {
                    state = State::Sell;
                    actions.date.push(history.date[i]);
                    actions.price.push(history.close[i]);
                    actions.action.push(state.clone());
                }
            },
        }
    }
    actions.roi();
    Ok(())
}
