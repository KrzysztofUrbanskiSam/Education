"""
A re-implementation of the second step in the seam carving algorithm: finding
the lowest-energy seam in an image. In this version of the algorithm, not only
is the energy value of the seam determined, but it's possible to reconstruct the
entire seam from the top to the bottom of the image.

The function you fill out in this module will be used as part of the overall
seam carving process. If you run this module in isolation, the lowest-energy
seam will be visualized:

    python3 seam_v2.py surfer.jpg surfer-seam-energy-v2.png
"""


import sys

from dataclasses import dataclass
from typing import List, Tuple
from energy import compute_energy
from utils import Color, read_image_into_array, write_array_into_image

@dataclass
class SeamEnergyWithBackPointer:
    """
    Represents the total energy of a seam along with a back pointer:

      - Stores the total energy of a seam that ends at some position in the
        image. The position is not stored because it can be inferred from where
        in a 2D grid this object appears.

      - Also stores the x-coordinate for the pixel in the previous row that led
        to this particular seam energy. This is the back pointer from which the
        entire seam can be reconstructed.

    You will implement this class as part of the second version of the vertical
    seam finding algorithm.
    """
    energy: int = 0
    x_coordinate_in_previous_row: int = 0


def compute_vertical_seam_v2(energy_data: List[List[int]]) -> Tuple[List[int], int]:
    """
    Find the lowest-energy vertical seam given the energy of each pixel in the
    input image. The image energy should have been computed before by the
    `compute_energy` function in the `energy` module.

    This is the second version of the seam finding algorithm. In addition to
    storing and finding the lowest-energy value of any seam, you will also store
    back pointers used to reconstruct the lowest-energy seam.

    At the end, you will return a list of x-coordinates where you would have
    returned a single x-coordinate instead.

    This is one of the functions you will need to implement. You may want to
    copy over the implementation of the first version as a starting point.
    Expected return value: a tuple with two values:

      1. The list of x-coordinates forming the lowest-energy seam, starting at
         the top of the image.
      2. The total energy of that seam.
    """
    high = len(energy_data)
    width = len(energy_data[0])
    energy_power_grid: List[List[SeamEnergyWithBackPointer]] = [[SeamEnergyWithBackPointer() for _ in row] for row in energy_data]

    for idx_col in range(width):
        energy_power_grid[0][idx_col] = SeamEnergyWithBackPointer(energy_data[0][idx_col])

    for idx_row in range(high):
        for idx_col in range(width):
            x_min = idx_col - 1 if idx_col > 0 else idx_col
            x_max = idx_col + 1 if idx_col < width - 1 else width - 1

            min_parent_idx_col = min(range(x_min, x_max + 1), key=lambda x_candidate:energy_power_grid[idx_row - 1][x_candidate].energy)

            energy_power_grid[idx_row][idx_col] = SeamEnergyWithBackPointer(energy_data[idx_row][idx_col] + energy_power_grid[idx_row - 1][min_parent_idx_col].energy)

    lowest_column = 0
    lowest_energy = energy_power_grid[high - 1][0].energy

    for idx_col in range(1, width):
        column_energy = energy_power_grid[high - 1][idx_col].energy
        if column_energy < lowest_energy:
            lowest_energy = column_energy
            lowest_column = idx_col

    out_raw: List[int] = []

    prev_row_column: int = lowest_column
    for idx_row in range(high, 0, -1):
        out_raw.append(energy_power_grid[idx_row][prev_row_column].energy)
        prev_row_column = energy_power_grid[idx_row][prev_row_column].x_coordinate_in_previous_row


    return out_raw[::-1], lowest_column


def visualize_seam_on_image(pixels: List[List[Color]], seam_xs: List[int]):
    """
    Draws a red line on the image along the given seam. This is done to
    visualize where the seam is.

    This is NOT one of the functions you have to implement.
    """

    w = len(pixels[0])

    new_pixels = [[p for p in row] for row in pixels]

    for idx_row, seam_x in enumerate(seam_xs):
        min_x = max(seam_x - 2, 0)
        max_x = min(seam_x + 2, w - 1)

        for idx_col in range(min_x, max_x + 1):
            new_pixels[idx_row][idx_col] = Color(255, 0, 0)

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
    seam_xs, min_seam_energy = compute_vertical_seam_v2(energy_data)

    print(f'Saving {output_filename}')
    visualized_pixels = visualize_seam_on_image(pixels, seam_xs)
    write_array_into_image(visualized_pixels, output_filename)

    print()
    print(f'Minimum seam energy was {min_seam_energy} at x = {seam_xs[-1]}')
