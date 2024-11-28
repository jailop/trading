def dataset_path():
    refPath = "../../datasets/btcusd-1min.path.txt"
    with open(refPath, "r", encoding="utf-8") as fd:
        return fd.read()

def prepare_message(line):
    tokens = line.strip().split(",")
    return json.dumps({
        "time": float(tokens[0]),
        "open": float(tokens[1]),
        "high": float(tokens[2]),
        "low": float(tokens[3]),
        "close": float(tokens[4]),
        "volume": float(tokens[5]),
    })


