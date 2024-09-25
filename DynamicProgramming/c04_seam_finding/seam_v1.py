"""
The second step in the seam carving algorithm: finding the energy of the lowest-
energy seam in an image. In this version of the algorithm, only the energy value
of the seam is determined. However, this version of the algorithm still forms
the basis of overall seam carving process.

If you run this module in isolation, the location of the _end_ of the seam will
be visualized:

    python3 seam_v1.py surfer.jpg surfer-seam-energy-v1.png
"""


import sys
from typing import List, Tuple
from energy import compute_energy
from utils import Color, read_image_into_array, write_array_into_image

def compute_vertical_seam_v1(energy_data: List[List[int]]) -> Tuple[int, int]:
    """
    Find the lowest-energy vertical seam given the energy of each pixel in the
    input image. The image energy should have been computed before by the
    `compute_energy` function in the `energy` module.

    This is the first version of the seam finding algorithm. You will implement
    the recurrence relation directly, outputting the energy of the lowest-energy
    seam and the x-coordinate where that seam ends.

    This is one of the functions you will need to implement. Expected return
    value: a tuple with two values:

      1. The x-coordinate where the lowest-energy seam ends.
      2. The total energy of that seam.
    """
    high = len(energy_data)
    width = len(energy_data[0])
    energy_power_grid = [[0 for _ in row] for row in energy_data]

    for idx_col in range(width):
        energy_power_grid[0][idx_col] = energy_data[0][idx_col]

    for idx_row in range(high):
        for idx_col in range(width):
            x_min = idx_col - 1 if idx_col > 0 else idx_col
            x_max = idx_col + 1 if idx_col < width - 1 else width - 1

            min_parent_energy = min(energy_power_grid[idx_row - 1][idx_col_candidate] for idx_col_candidate in range(x_min, x_max + 1))
            energy_power_grid[idx_row][idx_col] = energy_data[idx_row][idx_col] + min_parent_energy

    lowest_column = 0
    lowest_energy = energy_power_grid[high - 1][0]

    for idx_col in range(1, width):
        column_energy = energy_power_grid[high - 1][idx_col]
        if column_energy < lowest_energy:
            lowest_energy = column_energy
            lowest_column = idx_col

    return lowest_column, lowest_energy


def visualize_seam_end_on_image(pixels: List[List[Color]], end_x: int):
    """
    Draws a red box at the bottom of the image at the specified x-coordinate.
    This is done to visualize approximately where a vertical seam ends.

    This is NOT one of the functions you have to implement.
    """

    h = len(pixels)
    w = len(pixels[0])

    new_pixels: List[List[Color]] = [[p for p in row] for row in pixels]

    min_x = max(end_x - 5, 0)
    max_x = min(end_x + 5, w - 1)

    min_y = max(h - 11, 0)
    max_y = h - 1

    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            new_pixels[y][x] = Color(255, 0, 0)

    return new_pixels


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f'USAGE: {__file__} <input> <output>')
        sys.exit(1)

    input_filename = sys.argv[1]
    output_filename = sys.argv[2]

    print(f'Reading {input_filename}...')
    pixels = read_image_into_array(input_filename)

    print('Computing the energy...')
    energy_data = compute_energy(pixels)

    print('Finding the lowest-energy seam...')
    min_end_x, min_seam_energy = compute_vertical_seam_v1(energy_data)

    print(f'Saving {output_filename}')
    visualized_pixels = visualize_seam_end_on_image(pixels, min_end_x)
    write_array_into_image(visualized_pixels, output_filename)

    print()
    print(f'Minimum seam energy was {min_seam_energy} at x = {min_end_x}')
