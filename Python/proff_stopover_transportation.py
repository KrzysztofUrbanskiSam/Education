from collections import defaultdict
from heapq import heappop, heappush

graph = defaultdict(dict)
n = 0


def init(N, K, sCity, eCity, mLimit):
    global n, graph
    n = N
    graph.clear()
    for i in range(K):
        graph[sCity[i]][eCity[i]] = mLimit[i]
        graph[eCity[i]][sCity[i]] = mLimit[i]
    return


def add(sCity, eCity, mLimit):
    global graph
    graph[sCity][eCity] = mLimit
    graph[eCity][sCity] = mLimit
    return


def calculate(sCity, eCity, M, mStopover):
    global n, graph
    pq = []
    heappush(pq, (-30001, sCity))
    v = [0] * n

    while pq:
        m_lim, node = heappop(pq)
        v[node] = 1

        if v[eCity] == 1:
            all_vis = True
            for i in mStopover:
                if v[i] == 0:
                    all_vis = False
            if all_vis:
                return -m_lim

        for i in graph[node]:
            if v[i] == 0:
                heappush(pq, (max(m_lim, -graph[node][i]), i))

    return -1

init(5, 2, [0,1], [1,4], [50,90])
assert calculate(1, 4, 1, [3]) == -1
assert calculate(0, 4, 1, [1]) == 50
add(3, 4, 30)
assert calculate(0, 4, 1, [3]) == 30