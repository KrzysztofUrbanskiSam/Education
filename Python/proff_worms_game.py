from typing import List
from heapq import *

# row, col
DIRECTIONS = {0: (-1, 0), 1: (0, 1), 2: (1, 0), 3: (0, -1)}
DIRECTIONS_INV = {0: (1, 0), 1: (0, -1), 2: (-1, 0), 3: (0, 1)}

def is_out_of_range(row, col, size):
    if row > size - 1 or row < 0 or col > size -1 or col < 0:
        return True
    return False

class RESULT:
    def __init__(self):
        self.cnt = 0
        self.IDs = [0, 0, 0, 0, 0]

class Worm:
    def __init__(self, worm_id: int, length: int, head_row: int, head_col: int, tail_row: int, tail_col: int):
        self.idw = worm_id
        self.length = length
        self.head_row = head_row
        self.head_col = head_col
        self.tail_row = tail_row
        self.tail_col = tail_col
        self.bent_row = None
        self.bent_col = None
        self.potential = 0
        self.direction = 0

    def update(self):
        if self.bent_col == self.tail_col and self.bent_row == self.tail_row:
            self.bent_row = None
            self.bent_col = None

        if self.bent_col == None:
            self.direction += 1
            if self.direction >= 4:
                self.direction = 0

            self.bent_row = self.head_row
            self.bent_col = self.head_col

        next_head_row = self.head_row + DIRECTIONS[self.direction][0]
        next_head_col = self.head_col + DIRECTIONS[self.direction][1]

        # Check if outside grid
        if is_out_of_range(next_head_row, next_head_col, size):
            return False, []

        self.head_col = next_head_col
        self.head_row = next_head_row
        board.add(self.idw, self.head_col, self.head_row)

        if self.potential > 0:
            self.potential -= 1
            self.length += 1
            heappush(ranking, (-self.length, -self.idw))
        else:
            board.remove(self.idw, self.tail_row, self.tail_col)
            next_tail = self.get_next_coordinate(self.tail_row, self.tail_col)
            self.tail_col = next_tail[1]
            self.tail_row = next_tail[0]
        collsions_point = []
        if len(board.board[self.head_row][self.head_col]) >= 2:
            collsions_point.append((self.head_row, self.head_col))
        return True, collsions_point

    def delete(self):
        to_delete = (self.head_row, self.head_col)
        idx = 1
        while to_delete:
            board.remove(self.idw, to_delete[0], to_delete[1])
            if idx >= self.length:
                break
            to_delete = self.get_next_coordinate(to_delete[0], to_delete[1])

    def get_next_coordinate(self, row, col):
        for direction_id in DIRECTIONS.keys():
            new_col = col + DIRECTIONS[direction_id][1]
            new_row = row + DIRECTIONS[direction_id][0]
            if is_out_of_range(new_row, new_col, size):
                continue
            if self.idw in board.board[new_row][new_col]:
                return (new_row, new_col)
        return None

class Board:
    def __init__(self, N: int):
        self.board = [[set() for _ in range(N)] for _ in range(N)]

    def add(self, worm_id, col, row):
        self.board[row][col].add(worm_id)
        pass

    def remove(self, worm_id, row, col):
        self.board[row][col].remove(worm_id)
        pass

global current_time
current_time = 0

def init(N : int) -> None:
    global board, worms, ranking, size

    size = N
    board = Board(N)
    worms = {} # key is worm_id, value is worm
    ranking = []
    heapify(ranking)

def join(mTime : int, mID : int, mX : int, mY : int, mLength : int) -> None:
    update(mTime)
    for idx in range(mLength):
        y_idx = mY + idx
        board.add(mID, mX, y_idx)

    worm = Worm(mID, mLength, mY, mX, mY + mLength - 1, mX)
    worms[mID] = worm
    heappush(ranking, (-worm.length, -worm.idw))

def top5(mTime : int) -> RESULT:
    update(mTime)
    to_pop_back = []
    worms_ids_out = []
    while ranking:
        if len(worms_ids_out) >= 5:
            break
        ranking_data = heappop(ranking)
        worm_id = (-1) * ranking_data[1]
        worm_len = (-1) * ranking_data[0]
        if worm_id in worms.keys() and worm_len == worms[worm_id].length:
            worms_ids_out.append(worm_id)
            to_pop_back.append(ranking_data)

    for item in to_pop_back:
        heappush(ranking, item)

    ret = RESULT()
    ret.IDs = worms_ids_out
    ret.cnt = len(ret.IDs)
    return ret

def update(target_time: int):
    global current_time
    while current_time < target_time:
        do_update()
        current_time += 1

def do_update():
    collsion_points = [] # List of (row, col)
    worms_to_delete = []
    for worm_id in worms.keys():
        success, colision_point = worms[worm_id].update()
        if not success:
            worms_to_delete.append(worm_id)
        if colision_point:
            collsion_points.extend(colision_point)
    # Add worms_to_delete
    for point in collsion_points:
        worms_to_delete.extend(handle_collision(point))

    for worm_id in worms_to_delete:
        if worm_id in worms.keys():
            worms[worm_id].delete()
            del worms[worm_id]

def handle_collision(collision_point):
    worms_to_delete = []
    row = collision_point[0]
    col = collision_point[1]

    if len(board.board[row][col]) == 1:
        return worms_to_delete

    head_collsion_worms = set()
    no_head_collision_worms = set()
    for worm_id in board.board[row][col]:
        if worms[worm_id].head_row == row and worms[worm_id].head_col == col:
            head_collsion_worms.add(worm_id)
            worms_to_delete.append(worm_id)
        else:
            no_head_collision_worms.add(worm_id)

    for worm_id in no_head_collision_worms:
        for worm_id_2 in head_collsion_worms:
            worms[worm_id].potential += worms[worm_id_2].length
    return worms_to_delete





init(10)
join(0, 1, 1, 1, 3)
join(0, 2, 3, 1, 3)
join(0, 3, 6, 6, 4)
assert top5(1).IDs == [3, 2, 1]
join(3, 4, 1, 1, 4)
assert top5(4).IDs == [2, 4, 3]

join(6, 5, 1, 6, 4)
join(7, 6, 1, 0, 3)
join(8, 7, 6, 4, 3)
assert top5(9).IDs == [2, 5, 3, 7, 6]

join(10, 8, 1, 2, 4)
join(10, 9, 4, 2, 3)
join(10, 10, 1, 6, 4)
join(10, 11, 3, 3, 3)
assert top5(10).IDs == [2, 10, 8, 5, 3]

join(11, 12, 2, 7, 3)
assert top5(11).IDs == [10, 8, 5, 3, 12]

assert top5(12).IDs == [10, 5, 3, 12, 7]
join(14, 13, 3, 2, 3)
join(14, 14, 2, 1, 3)
join(14, 15, 1, 0, 3)
assert top5(15).IDs == [5, 15, 14, 13]

join(18, 16, 6, 2, 3)
join(21, 17, 4, 2, 4)
join(22, 18, 0, 6, 4)
join(22, 19, 3, 1, 4)
assert top5(23).IDs == [13, 19, 18, 17, 16]

join(24, 20, 1, 1, 4)
join(26, 21, 7, 7, 3)
join(26, 22, 5, 1, 5)
assert top5(27).IDs == [13, 22, 17, 20, 21]

join(32, 23, 6, 6, 4)
assert top5(33).IDs == [13, 22, 23, 20]