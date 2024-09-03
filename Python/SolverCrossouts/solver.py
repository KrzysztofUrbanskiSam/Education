from typing import Dict, List, Tuple

# cSpell:disable
board = """
SUBSTANCJA
TTKŁTOWETA
EAOOAŁRUJA
RRNMTNNCKS
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

class Solver:
    def __init__(self, grid: str, words: List[str]):
        self.grid: List[List[str]] = []
        self.words = words
        
        self.letter_locations: Dict[str, List[Tuple[int, int]]] = {}
        self.crossed: List[List[bool]] = []

        self.parse_grid(grid)

    
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
    
    
    def print_word(self, word: str) -> None:
        pass

solver = Solver(board, words)
solver.print_word(words[0])
