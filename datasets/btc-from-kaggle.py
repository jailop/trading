import os
import kagglehub

path = kagglehub.dataset_download("mczielinski/bitcoin-historical-data")
fullpath = os.path.join(path, os.listdir(path)[0])
with open("btcusd-1min.path.txt", "w", encoding="utf-8") as fd:
    fd.write(fullpath)
print(fullpath)
