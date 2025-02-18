# write binary search function that takes a sorted list and a target value and returns the index of the target if found or -1 otherwise

def binary_search(sorted_list, target):
    low = 0
    high = len(sorted_list) - 1

    while low <= high:
        mid = (low + high) // 2
        guess = sorted_list[mid]

        if guess == target:
            return mid
        elif guess > target:
            high = mid - 1
        else:
            low = mid + 1

    return -1

# write two examples of using binary_search function here
print(binary_search([1, 3, 5, 7, 9], 3))
print(binary_search([1, 3, 5, 7, 9], -1)) # should return -1 because -1 is not in the list
print(binary_search([1, 3, 5, 7, 9], 10)) # should return -1 because 10 is not in the list
print(binary_search([1, 3, 5, 7, 9], 6)) # should return -1 because 6 is not in the list
print(binary_search([1, 3, 5, 7, 9], 8)) # should return -1 because 8 is not in the list
print(binary_search([1, 3, 5, 7, 9], 4)) # should return -1 because 4 is not in the list
print(binary_search([1, 3, 5, 7, 9], 2)) # should return -1 because 2 is not in the list
print(binary_search([1, 3, 5, 7, 9], 0)) # should return -1 because 0 is not in the list
print(binary_search([1, 3, 5, 7, 9], 1)) # should return 0 because 1 is at index 0
print(binary_search([1, 3, 5, 7, 9], 9)) # should return 4 because 9 is at index 4
print(binary_search([1, 3, 5, 7, 9], 7)) # should return 3 because 7 is at index 3