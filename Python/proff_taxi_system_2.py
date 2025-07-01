from typing import List, Dict
import heapq

class Result:
    def __init__(self, mX, mY, mMoveDistance, mRideDistance):
        self.mX = mX
        self.mY = mY
        self.mMoveDistance = mMoveDistance
        self.mRideDistance = mRideDistance

class Taxi:
    def __init__(self, row: int, col: int):
        self.row = row
        self.col = col
        self.ride_distance = 0
        self.move_distance = 0

    def drive_taxi(self, passenger_col: int, passenger_row: int, dest_col: int, dest_row: int):
        to_passenger_distance = get_distance(self.col, self.row, passenger_col, passenger_row)
        ride_distance = get_distance(passenger_col, passenger_row, dest_col, dest_row)

        self.ride_distance += ride_distance
        self.move_distance += to_passenger_distance + ride_distance
        self.col = dest_col
        self.row = dest_row

class System:
    def __init__(self, city_length: int, taxis_num: int, max_dist_away: int, mXs : List[int], mYs : List[int]):
        self.length = city_length
        self.max_dist_away = max_dist_away
        self.taxis: Dict[int, Taxi] = {}

        for taxi_id in range(1, taxis_num + 1):
            self.taxis[taxi_id] = Taxi(mYs[taxi_id - 1], mXs[taxi_id - 1])

    def reset(self, taxi_id: int):
        taxi = self.taxis[taxi_id]
        to_return = Result(taxi.col, taxi.row, taxi.move_distance, taxi.ride_distance)
        self.taxis[taxi_id].move_distance = 0
        self.taxis[taxi_id].ride_distance = 0
        return to_return


    def pickup(self, start_row: int, start_col: int, end_row: int, end_col: int) -> int:
        nearest_taxi_id = self.get_nearest_taxi(start_row, start_col)
        if not nearest_taxi_id:
            return -1

        self.taxis[nearest_taxi_id].drive_taxi(start_col, start_row, end_col, end_row)

        return nearest_taxi_id

    def get_best(self, mNos: List[int]):
        best_taxis = []

        for taxi_id, taxi in self.taxis.items():
            heapq.heappush(best_taxis, ( (-1)* taxi.ride_distance, taxi_id))

        for idx in range(5):
            taxi_id = heapq.heappop(best_taxis)[1]
            mNos[idx] = taxi_id


    def get_nearest_taxi(self, start_row: int, start_col: int) -> int | None:
        nearest_taxis = []
        nearest_dist = self.max_dist_away
        for taxi_id, taxi in self.taxis.items():
            move_distance = get_distance(taxi.col, taxi.row, start_col, start_row)
            if move_distance > nearest_dist:
                continue
            if move_distance == nearest_dist:
                heapq.heappush(nearest_taxis, taxi_id)
                nearest_dist = move_distance
                continue
            nearest_taxis = [taxi_id]
            nearest_dist = move_distance

        if not nearest_taxis:
            return None
        return heapq.heappop(nearest_taxis)

def get_distance(s_col: int, s_row: int, e_col: int, e_row: int) -> int:
    return abs(s_col - e_col) + abs(s_row - e_row)

def init(N : int, M : int, L : int, mXs : List[int], mYs : List[int]) -> None:
    global hailing_system
    hailing_system = System(N, M, L, mXs, mYs)

def pickup(mSX : int, mSY : int, mEX : int, mEY : int) -> int:
    return hailing_system.pickup(mSY, mSX, mEY, mEX)

def reset(mNo : int) -> Result:
    return hailing_system.reset(mNo)

def getBest(mNos : List[int]) -> None:
    return hailing_system.get_best(mNos)