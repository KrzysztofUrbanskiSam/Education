import proff_online_store

proff_online_store.init()

assert 1 == proff_online_store.sell(1, 1, 1, 10)
assert 1 == proff_online_store.sell(2, 1, 2, 11)
assert 1 == proff_online_store.sell(3, 2, 1, 9)
assert 2 == proff_online_store.sell(4, 1, 1, 13)

assert proff_online_store.show(0, 0).IDs == [3, 1, 2, 4]

assert 1 == proff_online_store.sell(5, 2, 2, 14)
assert 3 == proff_online_store.sell(6, 1, 1, 13)
assert 2 == proff_online_store.sell(7, 1, 2, 6)
assert 2 == proff_online_store.sell(8, 2, 2, 7)
assert 2 == proff_online_store.sell(9, 2, 1, 11)
assert 3 == proff_online_store.sell(10, 2, 1, 10)


assert proff_online_store.show(0, 0).IDs == [7, 8, 3, 1, 10]
assert proff_online_store.show(1, 2).IDs == [8, 3, 10, 9, 5]
assert proff_online_store.show(1, 1).IDs == [7, 1, 2, 4, 6]
assert proff_online_store.show(2, 2).IDs == [7, 8, 2, 5]

assert proff_online_store.discount(1, 2, 6) == 1

assert proff_online_store.show(0, 0).IDs == [2, 8, 3, 1, 10]

assert proff_online_store.closeSale(7) == -1
assert proff_online_store.closeSale(1) == 10

assert 4 == proff_online_store.sell(11, 2, 1, 14)
assert 3 == proff_online_store.sell(12, 2, 2, 11)
assert 5 == proff_online_store.sell(13, 2, 1, 12)
assert 2 == proff_online_store.sell(14, 1, 2, 14)
assert 6 == proff_online_store.sell(15, 2, 1, 8)

assert proff_online_store.show(2, 1).IDs == [15, 3, 10, 9, 13]
assert proff_online_store.show(1, 2).IDs == [8, 15, 3, 10 ,9]

assert proff_online_store.discount(2, 1, 15) == 0

assert proff_online_store.show(0, 0).IDs == [2, 8, 12, 4, 6]
assert proff_online_store.show(2, 3).IDs == []

assert proff_online_store.closeSale(2) == 5
