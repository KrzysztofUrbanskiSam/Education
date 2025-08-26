from typing import Dict
from heapq import *
from collections import deque

ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
ALPHABET_IDX = {'A': 0, 'B': 1, 'C': 2, 'D': 3, 'E': 4, 'F': 5, 'G': 6, 'H': 7, 'I': 8, 'J': 9, 'K': 10, 'L': 11, 'M': 12, 'N': 13, 'O': 14, 'P': 15, 'Q': 16, 'R': 17, 'S': 18, 'T': 19, 'U': 20, 'V': 21, 'W': 22, 'X': 23, 'Y': 24, 'Z': 25}

class RESULT_E:
    def __init__(self, success, locname):
        self.success = success
        self.locname = locname

class RESULT_S:
    def __init__(self, cnt, carlist):
        self.cnt = cnt
        self.carlist = carlist # [str] * 5

class Zone:
    def __init__(self, letter: str, capacity: int):
        self.letter = letter
        self.slots_free = [f"{self.letter}{i:03d}" for i in range(capacity)]
        heapify(self.slots_free)
        self.nempty = capacity

    def enter(self):
        self.nempty -= 1
        slot = heappop(self.slots_free)
        return slot

    def leave(self, slot):
        self.nempty += 1
        heappush(self.slots_free, slot)


class Cars:
    def __init__(self):
        self.parked = {} # key platenum, value: (slot, start_park_time)
        self.towed = {}
        self.search_parked = {}
        self.search_towed = {}

    def add(self, plate: str, slot, time):
        self.parked[plate] = (slot, time)
        tow_times.append((time + limit, plate))
        self.search_parked.setdefault(plate[3:], set())
        self.search_parked[plate[3:]].add(plate[0:3])

    def tow(self, plate: str, time: int):
        zones[ALPHABET_IDX[self.parked[plate][0][0]]].leave(self.parked[plate][0])
        self.towed[plate] = (plate, self.parked[plate][1], time)
        del self.parked[plate]
        self.search_towed.setdefault(plate[3:], set())
        self.search_parked[plate[3:]].remove(plate[0:3])
        self.search_towed[plate[3:]].add(plate[0:3])

    def pullout(self, plate, at_time):
        if plate in self.parked.keys():
            to_return = at_time - self.parked[plate][1], self.parked[plate][0]
            del self.parked[plate]
            self.search_parked[plate[3:]].remove(plate[0:3])
            return to_return

        time_parked = limit
        time_towed = at_time - self.towed[plate][1] - limit
        to_return = (time_parked + time_towed * 5) * (-1), None
        del self.towed[plate]
        self.search_towed[plate[3:]].remove(plate[0:3])
        return to_return



def init(zones_num : int, capacity : int, timeout : int) -> None:
    global zones, cars, limit, tow_times
    limit = timeout

    zones = []
    cars = Cars()
    tow_times = deque()

    for idx in range(zones_num):
        zones.append(Zone(ALPHABET[idx], capacity))

def enter(m_time : int, plate_num : str) -> RESULT_E:
    global cars
    update(m_time)

    if plate_num in cars.towed.keys():
        cars.search_towed[plate_num[3:]].remove(plate_num[0:3])
        del cars.towed[plate_num]

    free_slots, letter_idx = pick_zone()
    if free_slots == 0:
        return RESULT_E(0, "")

    slot = zones[letter_idx].enter()
    cars.add(plate_num, slot, m_time)

    return RESULT_E(1, slot)

def pullout(m_time : int, plate_num : str) -> int:
    if m_time ==3611:
        pass
    update(m_time)
    # Car does not exist at all
    if plate_num not in cars.parked.keys() and plate_num not in cars.towed.keys():
        return -1

    return_data, slot = cars.pullout(plate_num, m_time)
    if slot:
        zones[ALPHABET_IDX[slot[0]]].leave(slot)

    return return_data

def search(mTime : int, mStr : str) -> RESULT_S:
    update(mTime)

    if mStr in cars.search_parked.keys():
        cars_parked = sorted([prefix + mStr for prefix in cars.search_parked[mStr]])
    else:
        cars_parked = []

    if len(cars_parked) >= 5:
        return RESULT_S(len(cars_parked[:5]), cars_parked[:5])

    if mStr in cars.search_towed.keys():
        cars_towed = sorted(prefix + mStr for prefix in cars.search_towed[mStr])
    else:
        cars_towed = []

    out = cars_parked + cars_towed

    return RESULT_S(len(out[0:5]), out[0:5])

def update(at_time: int):
    while tow_times and tow_times[0][0] <= at_time:
        tow_time, car_plate = tow_times.popleft()
        if car_plate in cars.parked.keys() and tow_time == cars.parked[car_plate][1] + limit:
            cars.tow(car_plate, at_time)

def pick_zone():
    # Perhaps to be refactored
    best_count = 0
    best_idx = -1
    for idx, z in enumerate(zones):
        if z.nempty > best_count:
            best_count = z.nempty
            best_idx = idx
    return (best_count, best_idx)

