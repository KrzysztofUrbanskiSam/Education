import java.io.IOException;
import java.util.HashSet;

public class LOG {
    private static final class State {
        final char[][] board;
        final int usedStamps;
        final int hashCode;

        private State(char[][] board, int usedStamps) {
            this.board = board;
            this.usedStamps = usedStamps;
            int hashCode = usedStamps;
            for (char[] row : board) {
                for (char n : row) {
                    hashCode = 31 * hashCode + n;
                }
            }
            this.hashCode = hashCode;
        }

        @SuppressWarnings("EqualsWhichDoesntCheckParameterClass")
        @Override
        public boolean equals(Object o) {
            State state = (State) o;
            return usedStamps == state.usedStamps && matrixEquals(board, state.board);
        }

        @Override
        public int hashCode() {
            return hashCode;
        }
    }


    public static void main(String[] args) throws IOException {
        Judge.run(new LOG());
    }

    public int solve(int n, char[][] logo, char[][][] stamps) {
        char[][] empty = new char[logo.length][logo.length];
        if (matrixEquals(logo, empty)) {
            return 0;
        }

        int result = -1;

        HashSet<State> states = new HashSet<>();
        HashSet<State> newStates = new HashSet<>();
        states.add(new State(empty, 0));

        for (int s = 0; s < n; s++) {
            char[][] stamp = copyOf(stamps[s]);
            final int limit = logo.length - stamp.length;

            for (int r = 0; r < 360; r += 90) {
                if (r > 0) {
                    rotate(stamp);
                }
                for (int y = 0; y <= limit; y++) {
                    for (int x = 0; x <= limit; x++) {
                        if (!canApplyStamp(stamp, y, x, logo)) {
                            continue;
                        }

                        for (State state : states) {
                            char[][] newBoard = copyOf(state.board);
                            applyStamp(stamp, y, x, newBoard);

                            if (matrixEquals(logo, newBoard)) {
                                int candidate = state.usedStamps + 1;
                                if (result == -1 || candidate < result) {
                                    result = candidate;

                                    // this is only micro-optimization - should work without it
                                    if (result == 1) {
                                        return 1;
                                    }
                                }
                            } else {
                                newStates.add(new State(newBoard, state.usedStamps + 1));
                            }
                        }
                    }
                }
            }
            states.addAll(newStates);
            newStates.clear();
        }

        return result;
    }

    private static boolean matrixEquals(char[][] m1, char[][] m2) {
        for (int y = 0; y < m1.length; y++) {
            for (int x = 0; x < m1[y].length; x++) {
                if (m1[y][x] != m2[y][x]) {
                    return false;
                }
            }
        }
        return true;
    }

    private static void applyStamp(char[][] stamp, int y, int x, char[][] board) {
        for (int sy = 0; sy < stamp.length; sy++) {
            for (int sx = 0; sx < stamp[sy].length; sx++) {
                if (stamp[sy][sx] == 1) {
                    board[y + sy][x + sx] = 1;
                }
            }
        }
    }

    private static boolean canApplyStamp(char[][] stamp, int y, int x, char[][] logo) {
        for (int sy = 0; sy < stamp.length; sy++) {
            for (int sx = 0; sx < stamp[sy].length; sx++) {
                if (stamp[sy][sx] == 1 && logo[y + sy][x + sx] == 0) {
                    return false;
                }
            }
        }
        return true;
    }

    private static char[][] copyOf(char[][] matrix) {
        char[][] copy = new char[matrix.length][matrix.length];
        for (int i = 0; i < matrix.length; i++) {
            System.arraycopy(matrix[i], 0, copy[i], 0, matrix[i].length);
        }
        return copy;
    }

    private static void rotate(char[][] m) {
        for (int y = 0; y < m.length; y++) {
            for (int x = 0; x < y; x++) {
                swap(m[y], x, m[x], y);
            }
        }
        for (char[] row : m) {
            for (int x = 0; x < m.length / 2; x++) {
                swap(row, x, row, m.length - 1 - x);
            }
        }
    }

    static void swap(char[] a1, int i1, char[] a2, int i2) {
        if (a1[i1] != a2[i2]) {
            char tmp = a1[i1];
            a1[i1] = a2[i2];
            a2[i2] = tmp;
        }
    }
}