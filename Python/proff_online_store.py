import heapq
class RESULT:
    def __init__(self, cnt: int, ids):
        self.cnt = cnt
        self.IDs = ids  # [int] * 5

class OnlineStore:
    def __init__(self):
        self.products = {} # key is ID value is tuple (cat, company, price, soldout)
        self.bucket = {} # Dict[category][company], value is set of IDS O(1)
        self.discounts = {}

        self.prices_heap_all = []
        self.prices_heap_by_category = {} # Dict of list
        self.prices_heap_by_company = {} # Dict of list

        for cat in range(1, 6):
            self.bucket[cat] = {}
            self.discounts[cat] = {}
            self.prices_heap_by_category[cat] = []
            for man in range(1, 6):
                self.bucket[cat][man] = set()
                self.discounts[cat][man] = 0

        for company in range(1, 6):
            # self.products_by_company[company] = set()
            self.prices_heap_by_company[company] = []


    def sell(self, mid, category, company, price):
        new_price = price + self.discounts[category][company]
        self.products[mid] = (category, company, new_price)
        self.bucket[category][company].add(mid)

        # Real price in price heaps
        heapq.heappush(self.prices_heap_all, (price, mid))
        heapq.heappush(self.prices_heap_by_category[category], (price, mid))
        heapq.heappush(self.prices_heap_by_company[company], (price, mid))

        return len(self.bucket[category][company])

    def close_sale(self, mid):
        if mid == 29454409:
            pass

        if mid not in self.products:
            return -1
        product_category = self.products[mid][0]
        product_company = self.products[mid][1]
        price_at_stop = self.products[mid][2] - self.discounts[product_category][product_company]
        self.bucket[product_category][product_company].remove(mid)
        del self.products[mid]
        return price_at_stop

    def discount(self, mCategory: int, mCompany: int, mAmount: int):

        to_stop_selling = set()

        to_heap_back = []
        while self.prices_heap_by_company[mCompany]:
            product = heapq.heappop(self.prices_heap_by_company[mCompany])

            product_id = product[1]
            if product_id not in self.products:
                continue
            product_cat = self.products[product_id][0]
            product_company = self.products[product_id][1]
            product_price_real = self.products[product_id][2] - self.discounts[product_cat][product_company]

            if product_cat != mCategory:
                to_heap_back.append((product_price_real, product_id))
                continue

            product_price_real_new = self.products[product_id][2] - self.discounts[product_cat][product_company] - mAmount

            if product_price_real_new <= 0:
                to_stop_selling.add(product_id)
                continue

            to_heap_back.append((product_price_real_new, product_id))

            if len(to_heap_back) >= 10000:
                break

        for item in to_heap_back:
            heapq.heappush(self.prices_heap_by_company[mCompany], item)



        to_heap_back = []
        while self.prices_heap_by_category[mCategory]:
            product = heapq.heappop(self.prices_heap_by_category[mCategory])

            product_id = product[1]
            if product_id not in self.products:
                continue

            product_cat = self.products[product_id][0]
            product_company = self.products[product_id][1]
            product_price_real = self.products[product_id][2] - self.discounts[product_cat][product_company]

            if product_company != mCompany:
                to_heap_back.append((product_price_real, product_id))
                continue

            product_price_real_new = self.products[product_id][2] - self.discounts[product_cat][product_company] - mAmount

            if product_price_real_new <= 0:
                to_stop_selling.add(product_id)
                continue

            to_heap_back.append((product_price_real_new, product_id))

            if len(to_heap_back) >= 10000:
                break

        for item in to_heap_back:
            heapq.heappush(self.prices_heap_by_category[mCategory], item)



        to_heap_back = []
        while self.prices_heap_all:
            product = heapq.heappop(self.prices_heap_all)

            product_id = product[1]
            if product_id not in self.products:
                continue
            product_cat = self.products[product_id][0]
            product_company = self.products[product_id][1]
            product_price_real = self.products[product_id][2] - self.discounts[product_cat][product_company]

            if not (product_company == mCompany and product_cat == mCategory):
                to_heap_back.append((product_price_real, product_id))
                continue

            product_price_real_new = self.products[product_id][2] - self.discounts[product_cat][product_company] - mAmount

            if product_price_real_new <= 0:
                to_stop_selling.add(product_id)
                continue

            to_heap_back.append((product_price_real_new, product_id))

            if len(to_heap_back) >= 10000:
                break

        for item in to_heap_back:
            heapq.heappush(self.prices_heap_all, item)

        self.discounts[mCategory][mCompany] += mAmount

        for product_id in to_stop_selling:
            self.close_sale(product_id)

        return len(shop.bucket[mCategory][mCompany])

    def show(self, how, code):
        products_sorted = []

        if how == 0:
            pass

        if how == 0:
            heap_to_iterate = self.prices_heap_all
        if how == 1:
            heap_to_iterate = self.prices_heap_by_category[code]
        if how == 2:
            heap_to_iterate = self.prices_heap_by_company[code]

        to_push_back = []
        while heap_to_iterate and len(products_sorted) <= 4:
            product = heapq.heappop(heap_to_iterate)

            if product[1] not in self.products:
                continue

            products_sorted.append(product[1])
            to_push_back.append((product[0], product[1]))

        for to_push in to_push_back:
            heapq.heappush(heap_to_iterate, to_push)

        return RESULT(len(products_sorted), products_sorted)

def init() -> None:
    global shop
    shop = OnlineStore()

def sell(mID : int, mCategory : int, mCompany : int, mPrice : int) -> int:
    return shop.sell(mID, mCategory, mCompany, mPrice)

def closeSale(mID : int) -> int:
    return shop.close_sale(mID)


def discount(mCategory : int, mCompany : int, mAmount : int) -> int:
    return shop.discount(mCategory, mCompany, mAmount)

def show(mHow : int, mCode : int) -> RESULT:
    return shop.show(mHow, mCode)