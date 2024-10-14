from typing import Dict, List, Tuple, Set

EDGES: List[List[List[int]]] =  [
    [
      [1, 4],
      [7, 11]
    ],
    [
      [0, 4],
      [2, 11],
      [7, 14]
    ],
    [
      [1, 11],
      [3, 10],
      [5, 7],
      [8, 5]
    ],
    [
      [2, 10],
      [4, 12],
      [5, 17]
    ],
    [
      [3, 12],
      [5, 13],
      [6, 3]
    ],
    [
      [2, 7],
      [3, 17],
      [4, 13],
      [6, 5]
    ],
    [
      [4, 3],
      [5, 6],
      [7, 4],
      [9, 8]
    ],
    [
      [0, 11],
      [1, 14],
      [6, 4],
      [8, 10]
    ],
    [
      [2, 5],
      [6, 9],
      [7, 10]
    ],
    []
  ]
START = 8

class Graph:
    def __init__(self, nodes_num: int):
        self.edges: Dict[int, Dict[int, int]] = {}

        for node_id in range(nodes_num):
            self.edges[node_id] = {}

    def add_edge(self, start_node: int, edge: List[int]):
        self.edges[start_node][edge[0]] = edge[1]

    def calculate_dijkstra(self, start_node: int) -> List[int]:
        distances = [-1 for _ in self.edges.keys()]
        distances[start_node] = 0

        edges_visited: Set[Tuple[int, int, int]] = set()
        edges_to_traverse: List[Tuple[int, int, int]] = []
        edges_to_traverse.extend(self.get_edges_to_traverse(start_node))

        while edges_to_traverse:
            current_edge = edges_to_traverse.pop(0)

            if current_edge in edges_visited:
                continue
            edges_visited.add(current_edge)

            start_node_idx = current_edge[0]
            next_node_idx = current_edge[1]
            dist_edge = current_edge[2]

            dist_to_next_node = distances[start_node_idx] + dist_edge

            if distances[next_node_idx] == -1 or dist_to_next_node < distances[next_node_idx]:
                distances[next_node_idx] = dist_to_next_node

            edges_to_traverse.extend(self.get_edges_to_traverse(next_node_idx))

        return distances


    def get_edges_to_traverse(self, node_start: int) -> List[Tuple[int, int, int]]:
        to_traverse: List[Tuple[int, int, int]] = []

        for next_node, dist in self.edges[node_start].items():
            to_traverse.append((node_start, next_node, dist))

        return to_traverse

def main():
    graph = Graph(len(EDGES))
    for node_idx, connections in enumerate(EDGES):
        for connection in connections:
            graph.add_edge(node_idx, connection)

    print(graph.calculate_dijkstra(START))

if __name__ == "__main__":
    main()