import unittest
from unittest.mock import patch

class TestBinarySearch(unittest.TestCase):

    def test_binary_search_normal_values(self):
        # Test with a small sorted list
        sorted_list = [1, 3, 5, 7, 9]
        self.assertEqual(binary_search(sorted_list, 1), 0)
        self.assertEqual(binary_search(sorted_list, 3), 1)
        self.assertEqual(binary_search(sorted_list, 5), 2)
        self.assertEqual(binary_search(sorted_list, 7), 3)
        self.assertEqual(binary_search(sorted_list, 9), 4)
        
        # Test with a larger sorted list
        large_sorted_list = list(range(1000))
        self.assertEqual(binary_search(large_sorted_list, 500), 500)
        self.assertEqual(binary_search(large_sorted_list, 0), 0)
        self.assertEqual(binary_search(large_sorted_list, 999), 999)

    def test_binary_search_target_not_in_list(self):
        sorted_list = [1, 3, 5, 7, 9]
        self.assertEqual(binary_search(sorted_list, -1), -1)
        self.assertEqual(binary_search(sorted_list, 2), -1)
        self.assertEqual(binary_search(sorted_list, 10), -1)

    def test_binary_search_empty_list(self):
        empty_list = []
        self.assertEqual(binary_search(empty_list, 1), -1)

    def test_binary_search_single_element(self):
        single_element_list = [42]
        self.assertEqual(binary_search(single_element_list, 42), 0)
        self.assertEqual(binary_search(single_element_list, -1), -1)

if __name__ == '__main__':
    unittest.main()