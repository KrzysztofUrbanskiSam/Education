import sys
from proff_automated_parking_lot import init, enter, pullout, search

CMD_INIT = 100
CMD_ENTER = 200
CMD_PULL_OUT = 300
CMD_SEARCH = 400

def run():
    Q = int(input())
    okay = False
    for q in range(Q):
        input_iter = iter(input().split())
        cmd = int(next(input_iter))
        if cmd == CMD_INIT:
            N = int(next(input_iter))
            M = int(next(input_iter))
            L = int(next(input_iter))
            init(N, M, L)
            okay = True
        elif cmd == CMD_ENTER:
            mTime = int(next(input_iter))
            mCarNo = next(input_iter)
            res_e = enter(mTime, mCarNo)
            ans = int(next(input_iter))
            if res_e.success != ans:
                okay = False
            if ans == 1:
                mStr = next(input_iter)
                if res_e.locname != mStr:
                    okay = False
                    # print("Fail in enter")
        elif cmd == CMD_PULL_OUT:
            mTime = int(next(input_iter))
            mCarNo = next(input_iter)
            ret = pullout(mTime, mCarNo)
            ans = int(next(input_iter))
            if ret != ans:
                okay = False
                # print("Fail in pullout")
        elif cmd == CMD_SEARCH:
            mTime = int(next(input_iter))
            mStr = next(input_iter)
            res_s = search(mTime, mStr)
            ans = int(next(input_iter))
            if res_s.cnt != ans:
                okay = False
            for i in range(ans):
                mCarNo = next(input_iter) + mStr
                if res_s.carlist[i] != mCarNo:
                    okay = False
        else:
            okay = False
    return okay


sys.stdin = open('/home/k.urbanski/SWTestSamples/proff_automated_parking_lot_input.txt', 'r')

T, MARK = map(int, input().split())

for tc in range(1, T + 1):
    score = MARK if run() else 0
    print("#%d %d" % (tc, score), flush = True)
