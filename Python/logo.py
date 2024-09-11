# Logo.py
from typing import List, Tuple
from copy import deepcopy
import itertools

SIZE_BOARD = 10
SIZE_STAMP = 4
TYPE_2D = List[List[int]]
logo_row = """
0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
1 1 1 1 0 0 0 0 0 0
0 1 0 1 0 0 0 0 0 0
0 1 1 1 0 0 0 0 0 0
0 1 0 1 0 0 0 0 0 0
1 1 1 1 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0"""


stamp1 = """
0 0 0 1
0 1 1 1
0 1 0 1
0 1 1 1
"""

stamp2 = """
0 0 0 0
0 1 1 0
0 0 0 0
0 0 0 0
"""

stamp3 = """
0 0 1 1
0 0 1 0
0 1 1 1
0 0 0 0
"""

stamp4 = """
0 1 1 1
0 0 0 1
1 1 1 1
0 0 0 1
"""

logo: List[List[int]] = []

def to_matrix(my_in: str) -> List[List[int]]:
    out: List[List[int]] = []

    for row in my_in.split("\n"):
        if not row:
            continue
        row_bla: List[int] = []
        for digit in row.split():
            row_bla.append(int(digit))

        out.append(row_bla)

    return out

def rotate_left(my_in: List[List[int]]) -> List[List[int]]:
    out: List[List[int]] = []

    col_size = 4
    row_size = 4

    for idx_col in range(col_size - 1, -1, -1):
        row: List[int] = []

        for idx_row in range(0, row_size):
            row.append(my_in[idx_row][idx_col])

        out.append(row)

    return out

TARGET_BOARD = to_matrix(logo_row)
s1 = to_matrix(stamp1)
s2 = to_matrix(stamp2)
s3 = to_matrix(stamp3)
s4 = to_matrix(stamp4)

stamps_idx = {0: s1, 1: s2, 2: s3, 3: s4}

stamps = [s1, s2, s3, s4]

rotated = rotate_left(s1)

def apply_stamp(initial_board: List[List[int]], stamp: List[List[int]], idx_row: int, idx_col: int) -> bool:
    original_board = deepcopy(initial_board)

    if idx_row + SIZE_STAMP >= SIZE_BOARD or idx_col + SIZE_STAMP >= SIZE_BOARD:
        return False

    for stamp_row in range(0, SIZE_STAMP):
        for stamp_col in range(0, SIZE_STAMP):
            stamp_state = stamp[stamp_row][stamp_col]
            logo_idx_row = idx_row + stamp_row
            logo_idx_col = idx_col + stamp_col
            state_logo = TARGET_BOARD[logo_idx_row][logo_idx_col]

            if state_logo != stamp_state:
                initial_board = original_board
                return False
            initial_board[logo_idx_row][logo_idx_col] = stamp_state

    return True


def check_stamps_combination(stamps: Tuple[List[List[int]]]) -> bool:
    initial_board = [[0 for _ in range(SIZE_BOARD)] for _ in range(SIZE_BOARD)]

    if len(stamps) == 2:
        pass

    for stamp in stamps:
        p0 = stamp
        p1 = rotate_left(p0)
        p2 = rotate_left(p1)
        p3 = rotate_left(p2)

        stamp_states = [p0, p1, p2, p3]

        for stamp_state in stamp_states:
            applied_success = False
            if applied_success:
                break

            for idx_row in range(0, SIZE_BOARD):
                if applied_success:
                    break

                for idx_col in range(0, SIZE_BOARD):
                    applied_success = apply_stamp(initial_board, stamp_state, idx_row, idx_col)

                    if applied_success:
                        break
    return initial_board == TARGET_BOARD

def generate_combinations(input_idxs: List[int], size: int) -> Tuple[List[List[int]]]:
    comb_idxs = list(itertools.combinations(input_idxs, size)) # type: ignore
    out = []

    for comb_idx in comb_idxs:
        o1 = []
        for c_i in comb_idx:
            o1.append(stamps_idx[c_i])
        out.append(o1)

    return out

def solve():
    result = -1
    for idx_combination in range(0, len(stamps)):
        combinations = generate_combinations(list(range(0, len(stamps_idx))), idx_combination)

        for combination in combinations:
            if check_stamps_combination(combination):
                result = idx_combination
                return result
    return result

print(f"Number of stamps {solve()}")




