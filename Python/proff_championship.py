from dataclasses import dataclass
from typing import Dict, List, Set

MY_INPUT="""1 20 ALA
1 30 ELA
1 50 OLA
1 30 OLAF
1 20 ULA
3 1 3
3 2 3
3 3 3
3 1 4
3 2 4
3 3 4
4 1 3
4 2 3
4 1 4
4 2 4
4 3 4
1 50 ALA
1 10 ELA
3 1 3
3 2 3
4 1 3
4 2 3
2 OLA
3 1 3
3 2 3
4 1 3
4 2 3
0"""

@dataclass
class PlayerMetadata:
    score: int
    position: int

def swap(arr: List[str], pos1: int, pos2: int):
    arr[pos1], arr[pos2] = arr[pos2], arr[pos1]

class Ranking:
    def __init__(self):
        self.rank_table: List[str] = []
        self.rank_by_name: Dict[str, PlayerMetadata] = {}
        self.players_disqualified: Set[str] = set()

    def add_score(self, score: int, player: str):
        if player in self.players_disqualified:
            return

        if player not in self.rank_by_name:
            self.rank_by_name[player] = PlayerMetadata(score, len(self.rank_table))
            self.rank_table.append(player)
            self.update_rank_table(player)

        elif score > self.rank_by_name[player].score:
            self.rank_by_name[player].score = score
            self.update_rank_table(player)

    def update_rank_table(self, player: str):
        if len(self.rank_table) < 2:
            return

        idx_player = self.rank_by_name[player].position
        idx_previous = idx_player - 1

        player_previous = self.rank_table[idx_previous]
        while self.rank_by_name[player_previous].score < self.rank_by_name[player].score:
            swap(self.rank_table, idx_player, idx_previous)
            self.rank_by_name[player_previous].position = idx_player
            self.rank_by_name[player].position = idx_previous
            idx_previous -= 1
            idx_player -= 1

            if idx_previous < 0:
                break
            player_previous = self.rank_table[idx_previous]


    def disqualify(self, player: str):
        self.players_disqualified.add(player)
        idx_player = self.rank_by_name[player].position

        # Shift results
        while idx_player < len(self.rank_table) - 1:
            idx_player_next = idx_player + 1
            self.rank_by_name[self.rank_table[idx_player_next]].position -= 1
            swap(self.rank_table, idx_player, idx_player_next)
            idx_player += 1
        del self.rank_table[-1]
        del self.rank_by_name[player]


    def get_result_page(self, page_num: int, page_size: int, sort_by_name: bool = False):
        idx_range_min = (page_num - 1) * page_size
        idx_range_max = page_num * page_size if page_num * page_size <= len(self.rank_table) else len(self.rank_table)

        if sort_by_name:
            table = sorted(self.rank_table)
        else:
            table = self.rank_table

        for player in table[idx_range_min:idx_range_max]:
            print(f"{self.rank_by_name[player].position + 1} {player} {self.rank_by_name[player].score}")


def main(my_input: str):
    ranking = Ranking()
    for line in my_input.split('\n'):
        line_actions = line.split()
        action = line_actions[0]

        if action == "0":
            print("END of Championship")

        # Add result
        if action == "1":
            score, name = int(line_actions[1]), line_actions[2]
            ranking.add_score(score, name)

        # Do disqualification
        if action == "2":
            ranking.disqualify(line_actions[1])

        # Print results
        if action == "3":
            print(f"==== {line} ====")
            ranking.get_result_page(int(line_actions[1]), int(line_actions[2]))

        if action == "4":
            print(f"==== {line} ====")
            ranking.get_result_page(int(line_actions[1]), int(line_actions[2]), True)

if __name__ == "__main__":
    main(MY_INPUT)
