import sys

from proff_road_destruction import init, add, remove, calculate

CMD_INIT = 100
CMD_ADD = 200
CMD_REMOVE = 300
CMD_CALC = 400

def run():
	q = int(sys.stdin.readline())
	okay = False

	mIdArr = []
	sCityArr = []
	eCityArr = []
	mTimeArr = []

	for i in range(q):
		inputarray = sys.stdin.readline().split()
		cmd = int(inputarray[0])

		if cmd == CMD_INIT:
			n = int(inputarray[1])
			k = int(inputarray[2])
			for _ in range(k):
				road = sys.stdin.readline().split()
				mIdArr.append(int(road[0]))
				sCityArr.append(int(road[1]))
				eCityArr.append(int(road[2]))
				mTimeArr.append(int(road[3]))

			init(n, k, mIdArr, sCityArr, eCityArr, mTimeArr)
			okay = True
		elif cmd == CMD_ADD:
			mId = int(inputarray[1])
			sCity = int(inputarray[2])
			eCity = int(inputarray[3])
			mTime = int(inputarray[4])
			add(mId, sCity, eCity, mTime)
		elif cmd == CMD_REMOVE:
			mId = int(inputarray[1])
			remove(mId)
		elif cmd == CMD_CALC:
			sCity = int(inputarray[1])
			eCity = int(inputarray[2])
			ans = int(inputarray[3])
			ret = calculate(sCity, eCity)
			if ans != ret:
				okay = False
		else:
			okay = False

	return okay


if __name__ == '__main__':
	sys.stdin = open('/home/k.urbanski/SWTestSamples/proff_road_destruction.txt', 'r')
	inputarray = sys.stdin.readline().split()
	TC = int(inputarray[0])
	MARK = int(inputarray[1])

	for testcase in range(1, TC + 1):
		score = MARK if run() else 0
		print("#%d %d" % (testcase, score), flush = True)