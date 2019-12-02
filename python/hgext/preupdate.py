import sys

lines = []
for line in sys.stdin:
    line = line.strip()
    if line.upper() in lines:
        print(f"file collision: {line}")
    else:
        lines.append(line.upper())
print("done!!!")
