from typing import Dict, List, Tuple

# cSpell:disable
board = """
SUBSTANCJA
TTKŁTOWETA
EAOOAŁRUJA
RRNMTNNCKA
OGSAAĆAŁIA
WKYZRTEIWK
NELEKTORAT
OAINOFELET
ŚWUIAWZSOP
ĆPMAESTROG
"""

words = ["ĆWIERĆNUTA", "ELEKTORAT", "KONSYLIUM", "MAESTRO", "MIOTEŁKA", "POSZWA", "PUNKTACJA",
         "SŁOMA", "STEROWNOŚĆ", "STOMATOLOG", "SUBSTANCJA", "SZLAK", "TATAR", "TELEFONIA",
         "TORCIK", "UTARG", "WERWA", "WIETRZYK"]

# cSpell:enable

DIRECTIONS = ["N", "S", "E", "W", "NE", "NW", "SE", "SW"]
OPPOSITIONS: Dict[str, str] = {
    "N": "S",
    "S": "N",
    "E": "W",
    "W": "E",
    "NW": "SE",
    "NE": "SW",
    "SE": "NW",
    "SW": "NE"}

# Movements, first is column then is row
MOVEMENTS: Dict[str, Tuple[int, int]] = {
    "N": (-1, 0),
    "NE": (-1, 1),
    "E": (0, 1),
    "SE": (1, 1),
    "S": (1, 0),
    "SW": (1, -1),
    "W": (0, -1),
    "NW": (-1, -1)}

class Solver:
    def __init__(self, grid: str, words: List[str]):
        self.grid: List[List[str]] = []
        self.words = words

        self.letter_locations: Dict[str, List[Tuple[int, int]]] = {}
        self.crossed: List[List[bool]] = []

        self._words_paths: Dict[str,List[Tuple[int,int]]] = {}
        for word in words:
            self._words_paths[word] = []
        self._solution = ""

        self.parse_grid(grid)
        self.solve()


    def parse_grid(self, grid: str):
        idx_row = 0
        for line in grid.split():
            if not line:
                continue

            line_letters: List[str] = []
            idx_col = 0

            for letter in line:
                line_letters.append(letter)
                self.letter_locations.setdefault(letter, [])
                self.letter_locations[letter].append((idx_row, idx_col))
                idx_col += 1

            self.grid.append(line_letters)
            self.crossed.append([False for _ in range(len(line))])
            idx_row += 1


    def solve(self):
        for word in self.words:
            self.find_word(word)

        for idx_row in range(0, len(self.grid)):
            for idx_col in range(0, len(self.grid[idx_row])):
                if not self.crossed[idx_row][idx_col]:
                    self._solution += self.grid[idx_row][idx_col]
        print(f"SOLUTION: {self._solution}")

    def find_word(self, word: str):
        rarest_letter, rarest_letter_idx = self._find_rarest_letter(word)

        word_found = False
        word_path = []
        idxs_prev = list(range(0, rarest_letter_idx))
        idxs_next = list(range(rarest_letter_idx + 1, len(word)))

        for location in self.letter_locations[rarest_letter]:
            if word_found: break

            for direction in DIRECTIONS:

                if direction == "SW":
                    pass

                path_prev = self._traverse(word, location, rarest_letter_idx, idxs_prev, direction)

                if len(path_prev) != len(idxs_prev):
                    continue

                path_next = self._traverse(word, location, rarest_letter_idx, idxs_next, OPPOSITIONS[direction])

                if len(path_next) != len(idxs_next):
                    continue

                word_path = path_prev + [location] + path_next
                word_found = True

        if word_found:
            self._words_paths[word] = word_path
            for coordinate in word_path:
                self.crossed[coordinate[0]][coordinate[1]] = True


    def _traverse(self, word: str, start: Tuple[int, int], letter_start_idx: int, letter_traverse_idx: List[int], direction: str) -> List[Tuple[int,int]]:
        path: List[Tuple[int,int]] = []
        vector = MOVEMENTS[direction]

        for traverse_idx in letter_traverse_idx:
            idx_diff = abs(traverse_idx - letter_start_idx)
            idx_row = start[0] + vector[0] * idx_diff
            idx_col = start[1] + vector[1] * idx_diff
            letter_at_idx = self.get_letter(idx_row, idx_col)

            if letter_at_idx != word[traverse_idx]:
                break

            path.append((idx_row, idx_col))
        return path

    def _find_rarest_letter(self, word: str) -> Tuple[str, int]:
        rarest_letter_idx = -1
        rarest_letter = ""
        rarest_letter_count = float("inf")
        for idx, letter in enumerate(word):
            if len(self.letter_locations[letter]) < rarest_letter_count:
                rarest_letter = letter
                rarest_letter_idx = idx
                rarest_letter_count = len(self.letter_locations[letter])
        return rarest_letter, rarest_letter_idx

    def print_word(self, word: str) -> None:
        if word not in self.words:
            print(f"ERROR: Cannot find word {word}")
            return

        if not len(self._words_paths[word]):
            print(f"ERROR: Provided word '{word}' was not found in diagram")
            return

        word_path_as_set = set(self._words_paths[word])
        print("-" * (len(self.grid) + 2))
        for idx_row in range(0, len(self.grid)):
            out_line = "|"
            for idx_col in range(0, len(self.grid[idx_row])):
                position = (idx_row, idx_col)
                if position in word_path_as_set:
                    out_line += self.grid[idx_row][idx_col]
                else:
                    out_line += " "
            out_line += "|"
            print(out_line)
        print("-" * (len(self.grid) + 2))



    def get_letter(self, idx_row: int, idx_col: int) -> str:
        if idx_row < 0 or idx_col < 0 or idx_row >= len(self.grid) or idx_col >= len(self.grid[idx_row]):
            return ""
        return self.grid[idx_row][idx_col]


solver = Solver(board, words)
for word in words:
    solver.print_word(word)
pass
