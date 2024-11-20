from collections import deque
from typing import Dict, List, Set, Deque, Tuple

CITY_SIZE = 10
MAX_PICKUP_DIST = 1

class TaxiSystem:
    def __init__(self, city_size: int, max_dist: int, tcxs: List[int], tcys: List[int]):
        self.size = city_size
        self.max_allowed_pickup_dist = max_dist
        self.grid: List[List[Set[int]]] = [[set() for _ in range(city_size)] for _ in range(city_size)]

        self.taxis: List[List[int]] = [] # List of Taxi metadata: [pos_x, pos_y, rank, dist_total, dist_with_client]
        self.ranking: List[int] = []

        for idx in range(len(tcxs)):
            self.taxis.append([tcxs[idx], tcys[idx], idx, 0, 0])
            self.grid[tcys[idx]][tcxs[idx]].add(idx)
            self.ranking.append(idx)


    def pickup(self, xs: int, ys: int, xd: int, yd: int) -> int:
        "return id of found taxi"

        distances: Dict[Tuple[int, int], int] = {(ys, xs) : 0}
        traversed: Set[Tuple[int, int]] = set()
        to_traverse: Deque[Tuple[int, int]]  = deque()
        to_traverse.append((ys, xs))

        ids_taxi_found: List[int] = []
        current_best_dist = -1

        while to_traverse:
            to_visit = to_traverse.popleft()

            if to_visit in traversed:
                continue

            traversed.add(to_visit)

            # Need to go through each field in 'layer' to get smallest id
            if current_best_dist != -1 and distances[to_visit] > current_best_dist:
                break

            for taxi_id in self.grid[to_visit[0]][to_visit[1]]:
                ids_taxi_found.append(taxi_id)
                current_best_dist = distances[to_visit]

            if distances[to_visit] == self.max_allowed_pickup_dist:
                continue

            to_traverse.extend(self.get_neighbors(to_visit[1], to_visit[0], distances, distances[to_visit]))


        if not ids_taxi_found:
            return -1

        closest_tax_id = min(ids_taxi_found) # Potential place to improve
        return closest_tax_id

    def get_neighbors(self, x: int, y: int, distances: Dict[Tuple[int, int], int], current_dist: int) -> List[Tuple[int, int]]:
        out: List[Tuple[int, int]] = []

        # Left
        if x - 1 >= 0:
            out.append((y, x - 1))
            distances[(y, x - 1)] = current_dist + 1

        # Right
        if x + 1 < self.size:
            out.append((y, x + 1))
            distances[(y, x + 1)] = current_dist + 1
        # Up
        if y - 1 >= 0:
            out.append((y - 1, x))
            distances[(y - 1, x)] = current_dist + 1

        # Up
        if y + 1 < self.size:
            out.append((y + 1, x))
            distances[(y + 1, x)] = current_dist + 1

        return out

def main():
    tcxs = [1, 9, 1] # taxi coordinates x
    tcys = [1, 9, 1] # taxi coordinates y

    assert len(tcxs) == len(tcys)

    system = TaxiSystem(CITY_SIZE, MAX_PICKUP_DIST, tcxs, tcys)

    taxi_idx = system.pickup(4, 4, 7, 7)
    assert taxi_idx == -1

    taxi_idx = system.pickup(1, 2, 7, 7)
    assert taxi_idx == 0

if __name__ == "__main__":
    main()