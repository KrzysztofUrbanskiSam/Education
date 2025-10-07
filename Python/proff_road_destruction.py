import heapq
from typing import List

global roads
roads = {}
global cities
cities = {}


def init(number_of_cities, number_of_roads, road_ids: List[int], s_city: List[int], e_city: List[int], m_time: List[int]):
    global roads, cities
    for idx in range(number_of_cities):
        cities[idx] = set()
    for idx in range(number_of_roads):
        road_id = road_ids[idx]
        s_cit = s_city[idx]
        e_cit = e_city[idx]
        cost = m_time[idx]
        roads[road_id] = (s_cit, e_cit, cost)
        cities[s_cit].add(road_id)

def add(road_id: int, s_city: int, e_city: int, m_time: int):
    global roads, cities
    roads[road_id] = (s_city, e_city, m_time)
    cities[s_city].add(road_id)

def remove(road_id: int):
    global roads, cities
    s_city = roads[road_id][0]
    del roads[road_id]
    cities[s_city].remove(road_id)

def calculate(s_city: int, e_city: int) -> int:
    global cities, roads

    time_best_with_destruction = -1
    time_no_destruction, path, _ = do_dijkstra(cities, roads, s_city, e_city)

    if time_no_destruction == -1:
        return -1

    road_ids_path = get_cities_path(s_city, e_city, path)

    for road_id in road_ids_path:
        road_to_save = roads[road_id]
        cities[road_to_save[0]].remove(road_id)
        current_time, path, _ = do_dijkstra(cities, roads, s_city, e_city)
        if current_time == -1:
            roads[road_id] = road_to_save
            cities[road_to_save[0]].add(road_id)
            return -1
        if current_time > time_best_with_destruction:
            time_best_with_destruction = current_time

        roads[road_id] = road_to_save
        cities[road_to_save[0]].add(road_id)

    return time_best_with_destruction - time_no_destruction

def do_dijkstra(cities, roads, s_city, e_city):
    distances = [10**8] * len(cities)
    path = [-1] * len(cities)
    distances[s_city] = 0
    path[s_city] = 0
    to_traverse = []
    heapq.heappush(to_traverse, (0, s_city))
    while to_traverse:
        current_dist, current_city = heapq.heappop(to_traverse)
        if current_dist > distances[current_city]:
            continue
        if current_city == e_city:
            return current_dist, path, distances

        for road in cities[current_city]:
            neighbour = roads[road][1]
            cost = roads[road][2]
            new_dist = current_dist + cost

            if new_dist < distances[neighbour]:
                distances[neighbour] = new_dist
                path[neighbour] = current_city
                heapq.heappush(to_traverse, (new_dist, neighbour))

    return -1, path, distances

def get_cities_path(s_city, e_city, path):
    global cities, roads
    walked_path = []
    current_city = e_city

    while current_city != s_city:
        rs_city = path[current_city]
        re_city = current_city

        for road_id in cities[rs_city]:
            if roads[road_id][1] == re_city:
                walked_path.append(road_id)
                break
        current_city = rs_city

    return walked_path