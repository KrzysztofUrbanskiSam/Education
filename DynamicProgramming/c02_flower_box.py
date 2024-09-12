from typing import List
plants = [3, 10, 3, 1, 2]
hights = [0 for _ in range(len(plants))]
pass

idx = 0

# O(n) - complexity, O(n) - space
while idx < len(plants):
    vi1 = plants[idx]
    if idx >= 2:
        vi1 += hights[idx - 2]

    vi2 = hights[idx - 1] if idx >= 1 else 0
    hights[idx] = max(vi1, vi2)
    idx += 1

print(hights)

# O(n) - complexity, O(1) - space
def f(nutrient: List[int]) -> int:
    a = 0 # f(i - 2)
    b = 0 # f(i - 1)

    for val in nutrient:
        a, b = b, max(a + val, b)
    return b

print(f(plants))