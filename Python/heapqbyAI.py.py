import heapq
import random

# Generate example data with random order
names = ["Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Hank", "Ivy", "Jack"]
ages = [25, 30, 20, 22, 28, 18, 27, 19, 24, 21]

# Combine into tuples and shuffle
people = list(zip(names, ages))
random.shuffle(people)

# Convert to (age, name) tuples for the heap
heap = [(age, name) for name, age in people]
heapq.heapify(heap)

# Extract the two youngest
youngest = [heapq.heappop(heap) for _ in range(2)]

# Convert back to (name, age) format
result = [(name, age) for age, name in youngest]

# Output the result
print(result)
print(heap)