from copy import deepcopy
from dataclasses import dataclass
from typing import Dict, List, Set, Tuple
MY_INPUT="""5
-199 569 -787 -453 7
-791 -454 754 -627 9
757 -626 -250 490 11
-246 490 783 342 10
781 343 490 735 11
5
-229 -333 1 120
170 19 4 -400
713 -526 209 -221
-543 238 -489 -99
632 418 234 -588

5
209 547 128 -685 1
130 -683 622 243 5
623 242 -119 206 12
-122 205 538 -620 5
541 -618 655 -396 12
5
741 -752 123 -679
288 -730 -122 619
-480 -14 169 484
585 -277 211 592
-145 196 128 481

5
-760 -621 -475 525 11
-473 529 -435 227 11
-433 222 -356 -542 10
-360 -541 609 307 4
613 304 647 737 3
5
-310 75 265 -713
155 696 532 -444
-261 -336 720 -541
215 604 57 225
261 529 759 -580

5
-217 464 439 176 2
438 172 -118 -488 4
-117 -487 459 285 13
464 286 619 580 2
623 575 -525 315 1
5
262 483 41 -56
-663 438 593 -745
-588 596 -749 -282
-554 -214 580 -93
581 -746 171 722

5
348 377 -547 775 10
-548 770 84 -495 2
81 -497 245 335 1
245 335 -518 -244 2
-519 -247 -633 -683 9
5
-42 205 -656 614
-646 -221 -557 -656
-461 9 663 693
722 593 133 -114
-469 -91 -273 -150

5
-613 154 -318 -404 13
-319 -398 -285 -26 4
-284 -26 144 -559 12
144 -559 -3 551 10
-1 553 -380 502 9
5
-430 -143 -362 -392
-347 669 651 -317
-87 338 293 -510
169 -359 -123 -138
664 186 -471 -581

5
7 669 259 -302 8
255 -298 130 282 9
129 284 -195 -259 6
-193 -259 522 -703 2
517 -702 236 282 2
5
-241 -740 -71 524
-491 -404 436 378
-239 -709 -486 -132
230 -636 -489 662
-405 124 115 412

5
168 -733 -766 511 7
-767 507 -382 -567 13
-381 -565 780 -337 9
777 -338 -295 355 2
-296 350 221 109 8
5
-65 773 -592 -212
-408 464 -207 -768
-177 197 -732 419
179 48 -405 475
-106 -107 -666 52

5
689 -401 51 764 3
49 763 -42 -345 11
-41 -344 628 66 5
628 71 -99 55 1
-97 58 -184 742 13
5
-650 113 -308 639
416 372 209 -674
130 353 -409 573
529 570 412 -736
-433 -371 448 651

5
329 595 -575 -125 7
-574 -127 -451 782 3
-453 781 -754 55 3
-756 53 -231 -407 8
-230 -408 246 716 6
5
642 60 297 -220
379 110 -260 -320
-329 -594 244 423
-711 228 727 -437
-15 760 -303 -557

-1"""

@dataclass
class Point:
    x: int
    y: int

    def __hash__(self) -> int:
        return hash(f"{self.x}_{self.y}")


@dataclass
class Edge:
    start: Point
    end: Point
    cost: int

    def __hash__(self) -> int:
        return hash(f"{self.start}_{self.end}_{self.cost}")

def calculate_simple_distance(p1: Point, p2: Point) -> int:
    return abs(p2.x - p1.x) + abs(p2.y - p1.y)


class MetroSolver:
    def __init__(self):
        self.metros: List[Edge] = []
        self.edges: Dict[Point, Dict[Point, int]] = {}

        self.start: Point = Point(-1, -1)
        self.end: Point = Point(-1, -1)

    def add_metro(self, start_x: int, start_y: int, end_x: int, end_y: int, cost: int):
        p1 = Point(start_x, start_y)
        p2 = Point(end_x, end_y)
        self.add_edge(p1, p2, cost)

        metro = Edge(p1, p2, cost)
        self.connect_metro_to_existing_metro_map(metro)
        self.metros.append(metro)

    def add_edge(self, p1: Point, p2: Point, cost: int):
        self.edges.setdefault(p1, {})
        self.edges.setdefault(p2, {})
        self.edges[p1][p2] = cost
        self.edges[p2][p1] = cost

    def connect_metro_to_existing_metro_map(self, new_metro: Edge):
        for existing_metro in self.metros:
            distances: Dict[Tuple[Point,Point], int] = {}
            # Start
            distances[new_metro.start, existing_metro.start] = calculate_simple_distance(new_metro.start, existing_metro.start)
            distances[new_metro.start, existing_metro.end] = calculate_simple_distance(new_metro.start, existing_metro.end)

            # End
            distances[new_metro.end, existing_metro.start] = calculate_simple_distance(new_metro.end, existing_metro.start)
            distances[new_metro.end, existing_metro.end] = calculate_simple_distance(new_metro.end, existing_metro.end)

            connection_shortest = sorted(distances, key=lambda x: distances[x])[0] # Type: ignore
            self.add_edge(connection_shortest[0], connection_shortest[1], distances[connection_shortest])

    def add_start_and_end_to_graph(self, xs: int, ys: int, xe: int, ye: int):
        self.start.x = xs
        self.start.y = ys
        self.end.x = xe
        self.end.y = ye

        self.edges[self.start] = {}
        self.edges[self.end] = {}

        direct_distance = calculate_simple_distance(self.start, self.end)
        self.edges[self.start][self.end] = direct_distance

        for metro in self.metros:
            self.connect_point_to_metro(self.start, metro)
            self.connect_point_to_metro(self.end, metro)

    def connect_point_to_metro(self, point: Point,  metro: Edge):
            dist1 = calculate_simple_distance(point, metro.start)
            dist2 = calculate_simple_distance(point, metro.end)
            if dist1 < dist2:
                self.add_edge(point, metro.start, dist1)
            else:
                self.add_edge(point, metro.end, dist2)

    def calculate_shortest_distance(self):
        distances: Dict[Point, int] = {}
        for point in self.edges.keys():
            distances[point] = -1
        distances[self.start] = 0

        edges_traversed: Set[Edge] = set()
        edges_to_traverse: List[Edge] = []
        edges_to_traverse.extend(self.get_edges_to_traverse(self.start))

        while edges_to_traverse:
            current_edge = edges_to_traverse.pop(0)

            if current_edge in edges_traversed:
                continue
            edges_traversed.add(current_edge)

            dist = distances[current_edge.start] + current_edge.cost
            if dist < distances[current_edge.end]:
                distances[current_edge.end] = dist
                edges_traversed.clear() # Can be smarter here

            if distances[current_edge.end] == -1:
                distances[current_edge.end] = dist


            edges_to_traverse.extend(self.get_edges_to_traverse(current_edge.end))

        print(distances[self.end])

    def get_edges_to_traverse(self, start_point: Point) -> List[Edge]:
        out: List[Edge] = []

        for end in self.edges[start_point]:
            edge = Edge(start_point, end, self.edges[start_point][end])
            out.append(edge)

        return out

def main(my_input: str):
    test_cases = my_input.split('\n\n')

    for test_case in test_cases:
        lines = test_case.strip().split('\n')
        solver_original = MetroSolver()
        count_metro = int(lines[0])

        for idx in range(1,count_metro + 1):
            metro_input = lines[idx]
            xs, ys, xe, ye, cost = metro_input.split()
            solver_original.add_metro(int(xs), int(ys), int(xe), int(ye), int(cost))

        requests_start_idx = count_metro + 2
        for request in lines[requests_start_idx:]:
            # Since I create graph I always have to work on 'fresh' grid
            solver_copy = deepcopy(solver_original)
            xs, ys, xe, ye = request.split()
            solver_copy.add_start_and_end_to_graph(int(xs), int(ys), int(xe), int(ye))
            solver_copy.calculate_shortest_distance()

        print('')


if __name__ == "__main__":
    main("\n" + MY_INPUT)