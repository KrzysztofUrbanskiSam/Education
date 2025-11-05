import sys
from proff_file_sahring import init, makeNet, addLink, addShareFile, downloadFile, getFileSize

CMD_INIT = 100
CMD_MAKENET = 200
CMD_ADDLINK = 300
CMD_SHARED = 400
CMD_DOWNLOAD = 500
CMD_GETSIZE = 600

MAX_COM = 1000
MAX_ONEFILE = 50

fileCnt = [0 for _ in range(MAX_COM)]
fileID = [[0 for _ in range(MAX_ONEFILE)] for _ in range(MAX_COM)]
fileSize = [[0 for _ in range(MAX_ONEFILE)] for _ in range(MAX_COM)]

comA = [0 for _ in range(MAX_COM * 2)]
comB = [0 for _ in range(MAX_COM * 2)]
Dis = [0 for _ in range(MAX_COM * 2)]

def run():
    global fileCnt, fileID, fileSize, comA, comB, Dis
    Q = int(input())
    okay = False
    for q in range(Q):
        input_iter = iter(input().split())
        cmd = int(next(input_iter))
        if cmd == CMD_INIT:
            n = int(next(input_iter))
            for i in range(n):
                in_iter = iter(input().split())
                fileCnt[i] = int(next(in_iter))
                for k in range(fileCnt[i]):
                    fileID[i][k] = int(next(in_iter))
                    fileSize[i][k] = int(next(in_iter))
            init(n, fileCnt, fileID, fileSize)
            okay = True
        elif cmd == CMD_MAKENET:
            k = int(next(input_iter))
            for i in range(k):
                in_iter = iter(input().split())
                comA[i] = int(next(in_iter))
                comB[i] = int(next(in_iter))
                Dis[i] = int(next(in_iter))
            makeNet(k, comA, comB, Dis)
        elif cmd == CMD_ADDLINK:
            time = int(next(input_iter))
            com1 = int(next(input_iter))
            com2 = int(next(input_iter))
            dis = int(next(input_iter))
            addLink(time, com1, com2, dis)
        elif cmd == CMD_SHARED:
            time = int(next(input_iter))
            com1 = int(next(input_iter))
            id = int(next(input_iter))
            size = int(next(input_iter))
            addShareFile(time, com1, id, size)
        elif cmd == CMD_DOWNLOAD:
            time = int(next(input_iter))
            com1 = int(next(input_iter))
            fid = int(next(input_iter))
            ret = downloadFile(time, com1, fid)
            ans = int(next(input_iter))
            if ret != ans:
                okay = False
        elif cmd == CMD_GETSIZE:
            time = int(next(input_iter))
            com1 = int(next(input_iter))
            fid = int(next(input_iter))
            ret = getFileSize(time, com1, fid)
            ans = int(next(input_iter))
            if ret != ans:
                print("Wrong")
                okay = False
        else:
            okay = False
    return okay


sys.stdin = open('/home/k.urbanski/SWTestSamples/proff_file_sharing.txt', 'r')

T, MARK = map(int, input().split())

for tc in range(1, T + 1):
    score = MARK if run() else 0
    print("#%d %d" % (tc, score), flush = True)