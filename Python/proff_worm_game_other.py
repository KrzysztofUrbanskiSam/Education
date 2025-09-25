from typing import List

class RESULT:
    def __init__(self):
        self.cnt = 0
        self.IDs = [0, 0, 0, 0, 0]

class Worm:
    def __init__(self, id_, x, y, length):
        self.id_ = id_
        self.head = (x, y)
        self.tail = (x, y+length-1)
        self.length = length
        self.growth = 0
        self.direction = 0 # 0:up, 1:right, 2:down, 3:left

    def move(self):
        #check if the worm is straight
        if (self.head[0] == self.tail[0]) or (self.head[1] == self.tail[1]):
            self.direction = (self.direction + 1) & 3

        self.head = (self.head[0]+dx[self.direction], self.head[1]+dy[self.direction])
        if self.growth > 0:
            self.growth -= 1
            self.length += 1
        else:
            self.tail = (self.tail[0]+dx[(self.direction-1)&3], self.tail[1]+dy[(self.direction-1)&3])
        pass

    def colision(self, other):
        pos = (other.head[0], other.tail[1]) if other.direction % 2 == 0 else (other.tail[0], other.head[1])

        if (self.head[0] == pos[0]) and (self.head[1] >= min([other.head[1],other.tail[1]])) and (self.head[1] <= max([other.head[1],other.tail[1]])):
            return True
        if (self.head[1] == pos[1]) and (self.head[0] >= min([other.head[0],other.tail[0]])) and (self.head[0] <= max([other.head[0],other.tail[0]])):
            return True
        return False

t = None
n = None
worms = []

dy = [-1, 0, 1, 0]
dx = [0, 1, 0, -1]

def simulate(mTime):
    global t, n, worms

    while t < mTime:
        remove = [False]*len(worms)
        for worm in worms:
            worm.move()

        for i, worm in enumerate(worms):
            if max(worm.head) >= n or min(worm.head) < 0:
                remove[i] = True
                continue
            for other in worms:
                if worm != other and worm.colision(other):
                    remove[i] = True
                    other.growth += worm.length

        new_worms = []
        for i, worm in enumerate(worms):
            if remove[i]:
                continue
            new_worms.append(worm)

        worms = new_worms
        t += 1

def init(N : int) -> None:
    global t, n, worms

    worms = []
    n = N
    t = 0

def join(mTime : int, mID : int, mX : int, mY : int, mLength : int) -> None:
    global t, n, worms
    simulate(mTime)
    worms.append(Worm(mID, mX, mY, mLength))

def top5(mTime : int) -> RESULT:
    simulate(mTime)
    my_worms = [(w.length,w.id_) for w in worms]
    my_worms.sort(reverse=True)
    ret = RESULT()
    for i in range(min(5,len(my_worms))):
        ret.IDs[i] = my_worms[i][1]
    ret.cnt = len(my_worms[:5])
    return ret