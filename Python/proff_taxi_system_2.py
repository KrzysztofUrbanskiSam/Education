from typing import List, Dict
import heapq

class Result:
  def __init__(self, mX, mY, mMoveDistance, mRideDistance):
    self.mX = mX
    self.mY = mY
    self.mMoveDistance = mMoveDistance
    self.mRideDistance = mRideDistance

class Taxi:
    def __init__(self, x, y, bucket_x, bucket_y):
        self.x = x
        self.y = y
        self.bucket_x = bucket_x
        self.bucket_y = bucket_y
        self.dist_move = 0
        self.dist_ride = 0

directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 0), (0, 1), (1, -1), (1, 0), (1, 1)]
def get_distance(s_col: int, s_row: int, e_col: int, e_row: int) -> int:
    return abs(s_col - e_col) + abs(s_row - e_row)

global divider, taxis, buckets
taxis: Dict[int, Taxi] = {}

def init(_ : int, M : int, L : int, mXs : List[int], mYs : List[int]) -> None:
    global divider, buckets
    divider = L
    buckets = [[set() for _ in range(10)] for _ in range(10)]

    for taxi_id in range(1, M + 1):
        bucket_id = mXs[taxi_id - 1] // divider, mYs[taxi_id - 1] // divider
        taxis[taxi_id] = Taxi(mYs[taxi_id - 1], mXs[taxi_id - 1], bucket_id[0], bucket_id[1])
        buckets[bucket_id[1]][bucket_id[0]].add(taxi_id)

def pickup(start_col : int, start_row : int, end_col : int, end_row : int) -> int:
    global taxis, divider, buckets

    # Get nearest Taxi
    start_bucket_id = start_col //divider, start_row //divider

    taxis_to_check = [] # List of taxis ids
    for direction in directions:
        search_bckt_x = start_bucket_id[0] + direction[0]
        search_bckt_y = start_bucket_id[1] + direction[1]
        if search_bckt_x < 0 or search_bckt_x > 9 or search_bckt_y < 0 or search_bckt_y > 9 :
            continue
        if buckets[search_bckt_y][search_bckt_x]:
            taxis_to_check.extend(list(buckets[search_bckt_y][search_bckt_x]))

    nearest_dist = divider
    nearest_taxis = []
    for taxi_id in taxis_to_check:
        move_distance = get_distance(taxis[taxi_id].x, taxis[taxi_id].y, start_col, start_row)
        if move_distance > nearest_dist:
            continue
        if move_distance == nearest_dist:
            heapq.heappush(nearest_taxis, taxi_id)
            nearest_dist = move_distance
            continue
        nearest_taxis = [taxi_id]
        nearest_dist = move_distance

    if not nearest_taxis:
        return -1
    nearest_taxi_id = heapq.heappop(nearest_taxis)


    buckets[taxis[nearest_taxi_id].bucket_y][taxis[nearest_taxi_id].bucket_x].remove(nearest_taxi_id)

    to_passenger_distance = get_distance(taxis[nearest_taxi_id].x, taxis[nearest_taxi_id].y, start_col, start_row)
    ride_distance = get_distance(start_col, start_row, end_col, end_row)
    taxis[nearest_taxi_id].dist_ride += ride_distance
    taxis[nearest_taxi_id].dist_move += to_passenger_distance + ride_distance
    taxis[nearest_taxi_id].x = end_col
    taxis[nearest_taxi_id].y = end_row
    taxis[nearest_taxi_id].bucket_x = end_col // divider
    taxis[nearest_taxi_id].bucket_y = end_row // divider

    buckets[taxis[nearest_taxi_id].bucket_y][taxis[nearest_taxi_id].bucket_x].add(nearest_taxi_id)

    return nearest_taxi_id

def reset(taxi_id : int) -> Result:
    global taxis
    to_return = Result(taxis[taxi_id].x, taxis[taxi_id].y, taxis[taxi_id].dist_move, taxis[taxi_id].dist_ride)
    taxis[taxi_id].dist_ride = 0
    taxis[taxi_id].dist_move = 0
    return to_return

def getBest(list_to_return : List[int]) -> None:
    global taxis
    best_taxis = []

    for taxi_id, taxi in taxis.items():
        heapq.heappush(best_taxis, ( (-1)* taxi.dist_ride, taxi_id))

    for idx in range(5):
        taxi_id = heapq.heappop(best_taxis)[1]
        list_to_return[idx] = taxi_id