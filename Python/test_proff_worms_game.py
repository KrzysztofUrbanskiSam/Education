import sys
from proff_worm_game_other import init, join, top5

CMD_INIT = 100
CMD_JOIN = 200
CMD_TOP5 = 300

def run():
    Q = int(input())
    okay = False
    for q in range(Q):
        input_iter = iter(input().split())
        cmd = int(next(input_iter))
        if cmd == CMD_INIT:
            N = int(next(input_iter))
            init(N)
            okay = True
        elif cmd == CMD_JOIN:
            mTime = int(next(input_iter))
            mID = int(next(input_iter))
            mX = int(next(input_iter))
            mY = int(next(input_iter))
            mLength = int(next(input_iter))
            join(mTime, mID, mX, mY, mLength)
        elif cmd == CMD_TOP5:
            mTime = int(next(input_iter))
            user_ans = top5(mTime)
            correct_ans = int(next(input_iter))
            if user_ans.cnt != correct_ans:
                okay = False
            for i in range(correct_ans):
                correct_keyword = int(next(input_iter))
                if correct_keyword != user_ans.IDs[i]:
                    okay = False
        else:
            okay = False
    return okay


sys.stdin = open('/home/k.urbanski/SWTestSamples/input_worm_game.txt', 'r')

T, MARK = map(int, input().split())

for tc in range(1, T + 1):
    score = MARK if run() else 0
    print("#%d %d" % (tc, score), flush = True)
