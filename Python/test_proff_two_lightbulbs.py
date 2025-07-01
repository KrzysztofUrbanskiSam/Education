import sys


filename = "/home/k.urbanski/Desktop/sample_input_bulbs.txt"

from collections import namedtuple
Bulb = namedtuple('Bulb11', ['start', 'end'])


def solve_the_same_start(x_bulb: Bulb, y_bulb: Bulb):
    if x_bulb.end > y_bulb.end:
        return y_bulb.end - y_bulb.start
    return x_bulb.end - x_bulb.start

def solve_normal(bulb_first: Bulb, bulb_second: Bulb):
    # No overlap
    if bulb_second.start >= bulb_first.end:
        return 0
    # Full overlap
    if bulb_second.end <= bulb_first.end:
        return bulb_second.end - bulb_second.start
    # Partly inside
    return bulb_first.end - bulb_second.start

def solve(x_bulb: Bulb, y_bulb: Bulb):
        if x_bulb.start == y_bulb.start:
            return solve_the_same_start(x_bulb, y_bulb)
        else:
            if x_bulb.start < y_bulb.start:
                return solve_normal(x_bulb, y_bulb)
            else:
                return solve_normal(y_bulb, x_bulb)

TC = 0
current_tc = 1
with open(filename) as file:
    for line in file:
        if not TC:
            TC = int(line.strip())
            continue

        a, b, c, d, expected = map(int, line.split())
        x_bulb = Bulb(a, b)
        y_bulb = Bulb(c, d)
        result = solve(x_bulb, y_bulb)

        if result != expected:
            print(f"Test case {a, b, c, d, expected} failed")


        print(f"#{current_tc} {result}")
        current_tc += 1
