import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LOG {
    public static void main(String[] args) throws IOException {
        Judge.run(new LOG());
    }

    private static final class Point {
        final int y;
        final int x;

        private Point(int y, int x) {
            this.y = y;
            this.x = x;
        }
    }

    private static final class StampVariant {
        final List<Point> validPoints = new ArrayList<>();
        final char[][] stamp;

        public StampVariant(char[][] stamp) {
            this.stamp = stamp;
        }

        void initValidPoints(char[][] logo) {
            final int limit = logo.length - stamp.length;
            for (int y = 0; y <= limit; y++) {
                for (int x = 0; x <= limit; x++) {
                    if (canApplyStamp(y, x, logo)) {
                        validPoints.add(new Point(y, x));
                    }
                }
            }
        }

        void applyStamp(int y, int x, char[][] board) {
            for (int sy = 0; sy < stamp.length; sy++) {
                for (int sx = 0; sx < stamp[sy].length; sx++) {
                    if (stamp[sy][sx] == 1) {
                        board[y + sy][x + sx] = 1;
                    }
                }
            }
        }

        private boolean canApplyStamp(int y, int x, char[][] logo) {
            for (int sy = 0; sy < stamp.length; sy++) {
                for (int sx = 0; sx < stamp[sy].length; sx++) {
                    if (stamp[sy][sx] == 1 && logo[y + sy][x + sx] == 0) {
                        return false;
                    }
                }
            }
            return true;
        }
    }

    private final List<List<StampVariant>> stampVariants = new ArrayList<>();
    private final Map<String, Integer> resultCache = new HashMap<>();

    public int solve(int n, char[][] logo, char[][][] stamps) {
        char[][] board = new char[logo.length][logo.length];
        if (matrixEquals(logo, board)) {
            return 0;
        }
        stampVariants.clear();
        initStampVariants(n, logo, stamps);
        resultCache.clear();
        return solve(logo, board, 0);
    }

    private void initStampVariants(int n, char[][] logo, char[][][] stamps) {
        for (int s = 0; s < n; s++) {
            List<StampVariant> variants = new ArrayList<>(4);
            char[][] stamp = copyOf(stamps[s]);
            variants.add(new StampVariant(stamp));
            for (int r = 90; r < 360; r += 90) {
                stamp = copyOf(stamp);
                rotate(stamp);
                variants.add(new StampVariant(stamp));
            }
            for (StampVariant variant : variants) {
                variant.initValidPoints(logo);
            }
            this.stampVariants.add(variants);
        }
    }

    private int solve(final char[][] logo, final char[][] board, final int stampNo) {
        if (stampNo >= stampVariants.size()) {
            return -1;
        }

        // check if we already visited this state
        String stateId = getStateId(board, stampNo);
        Integer cached = resultCache.get(stateId);
        if (cached != null) {
            return cached;
        }

        // stamp not used
        int result = solve(logo, board, stampNo + 1);

        if (result == 1) {
            resultCache.put(stateId, 1);
            return 1;
        }

        // all possible stamp applications
        char[][] newBoard = new char[board.length][board.length];
        for (StampVariant variant : stampVariants.get(stampNo)) {
            for (Point point : variant.validPoints) {
                copy(board, newBoard);
                variant.applyStamp(point.y, point.x, newBoard);
                if (matrixEquals(newBoard, logo)) {
                    resultCache.put(stateId, 1);
                    return 1;
                }
                int candidate = solve(logo, newBoard, stampNo + 1);
                if (candidate != -1) {
                    if (result == -1 || candidate + 1 < result) {
                        result = candidate + 1;
                    }
                }
            }
        }

        resultCache.put(stateId, result);
        return result;
    }

    private static String getStateId(char[][] board, int stampNo) {
        StringBuilder sb = new StringBuilder();
        for (char[] chars : board) {
            for (char c : chars) {
                sb.append(c);
            }
        }
        sb.append(stampNo);
        return sb.toString();
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

    private static char[][] copyOf(char[][] matrix) {
        char[][] copy = new char[matrix.length][matrix.length];
        copy(matrix, copy);
        return copy;
    }

    private static void copy(char[][] source, char[][] target) {
        for (int i = 0; i < source.length; i++) {
            System.arraycopy(source[i], 0, target[i], 0, source[i].length);
        }
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