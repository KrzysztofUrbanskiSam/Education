from heapq import heapify, heappop, heappush
global roads
roads = {}

def init(building_count: int, roads_count: int, s_building: int, e_building, m_distance):
    global roads
    for i in range(building_count):
        roads[i] = {}
    for idx in range(roads_count):
        roads[s_building[idx]][e_building[idx]] = m_distance[idx]
        roads[e_building[idx]][s_building[idx]] = m_distance[idx]

def add(s_building: int, e_building: int, m_distance: int):
    global roads
    roads[s_building][e_building] = m_distance
    roads[e_building][s_building] = m_distance


def calculate(coffee_num: int, m_coffee, bakery_count: int, m_bakery, limit: int):
    global roads
    distances = [[float("inf")] * len(roads), [float("inf")] * len(roads) ]

    to_visit = []
    heapify(to_visit)

    for b_idx in m_coffee:
        distances[0][b_idx] = 0
        to_visit.append((0, 0, b_idx))

    for b_idx in m_bakery:
        distances[1][b_idx] = 0
        to_visit.append((0, 1, b_idx))

    min_dist = float("inf")

    while to_visit:
        curr_dist, b_type, b_idx = heappop(to_visit)
        if curr_dist > distances[b_type][b_idx] or curr_dist > min_dist:
            continue
        if distances[0][b_idx] != 0 and distances[1][b_idx] != 0:
            min_dist = min(min_dist, distances[0][b_idx] + distances[1][b_idx])
        for neighbour_idx, neighbour_dist in roads[b_idx].items():
            dist_to_neighbour = curr_dist + neighbour_dist
            if dist_to_neighbour <= limit and distances[b_type][neighbour_idx] > dist_to_neighbour:
                distances[b_type][neighbour_idx] = dist_to_neighbour
                heappush(to_visit, (dist_to_neighbour, b_type, neighbour_idx))
    if min_dist != float("inf"):
        return min_dist

    return -1