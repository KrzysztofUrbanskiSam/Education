from typing import Dict, List, Tuple

def change_making(denominations: List[int], target: int) -> int:
    "Basing on denominations we have calculate minimum number of coins"
    decision_cache: Dict[Tuple[int, int], int] = {}

    def subproblem(i: int, target: int) -> int:
        if (i, target) in decision_cache: return decision_cache[(i, target)]

        # take_coin
        coin_value = denominations[i]
        if coin_value > target:
            count_when_coin_taken = 1000
        elif coin_value == target:
            count_when_coin_taken = 1
        else:
            count_when_coin_taken = 1 + subproblem(i, target - coin_value)

        # leave coin
        if i == 0:
            count_when_coin_left = 1000
        else:
            count_when_coin_left = subproblem(i - 1, target)

        optimal = min(count_when_coin_taken, count_when_coin_left)
        decision_cache[(i, target)] = optimal
        return optimal

    return subproblem(len(denominations) - 1, target)

print(change_making([1, 5, 12, 19], 16))