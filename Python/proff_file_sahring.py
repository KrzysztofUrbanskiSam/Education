from typing import List
from heapq import heapify, heappop, heappush

global computers
global files
global links
computers = {}
files = {}
links = {}

def init(N: int, mShareFileCnt: List[int], mFileID: List[List[int]], mFileSize: List[List[int]]) -> None:
    global computers, files, links
    for computer_id in range(1, N + 1):
        links[computer_id] = {}
        computers[computer_id] = {'files_shared': {}, 'files_downloading': {}, 'files_downloaded': set()}

        for file_idx in range(0, mShareFileCnt[computer_id - 1]):
            file_id = mFileID[computer_id - 1][file_idx]
            computers[computer_id]['files_shared'][file_id] = 0
            files[file_id] = {'size': mFileSize[computer_id - 1][file_idx], 'time': {}, 'where': set([computer_id])}
            files[file_id]['time'][computer_id] = 0


def makeNet(K: int, mComA: List[int], mComB: List[int], mDis: List[int]) -> None:
    for idx in range(K):
        addLink(0, mComA[idx], mComB[idx], mDis[idx])


def addLink(mTime: int, mComA: int, mComB: int, mDis: int) -> None:
    global links
    links[mComA][mComB] = (mTime, mDis)
    links[mComB][mComA] = (mTime, mDis)


def addShareFile(mTime: int, mComA: int, mFileID: int, mSize: int) -> None:
    global computers, files
    computers[mComA]['files_shared'][mFileID] = mTime
    files[mFileID]['size'] = mSize
    files[mFileID]['where'].add(mComA)
    files[mFileID].setdefault('time', {})
    files[mFileID]['time'][mComA] = mTime


def downloadFile(mTime: int, mComA: int, mFileID: int) -> int:
    global computers, files, links
    if mFileID not in files:
        return 0
    if mFileID in computers[mComA]['files_shared'] or mFileID in computers[mComA]['files_downloaded']:
        return files[mFileID]['size']

    computers[mComA]['files_downloading'][mFileID] = mTime
    files_count = 0
    queue = [(0, mComA)]
    heapify(queue)
    visited = set()
    while queue:
        cc = heappop(queue)
        current_dist, current_computer = cc
        if current_computer in visited:
            continue
        visited.add(current_computer)

        if mFileID in computers[current_computer]['files_shared']:
            files_count += 1

        for neighbour in links[current_computer]:
            new_dist = current_dist + links[current_computer][neighbour][1]
            if new_dist <= 5000:
                heappush(queue, (new_dist, neighbour))

    return files_count


def getFileSize(mTime: int, mComA: int, mFileID: int) -> int:
    global computers, files, links
    if mFileID in computers[mComA]['files_shared'] or mFileID in computers[mComA]['files_downloaded']:
        return files[mFileID]['size']
    if mFileID not in computers[mComA]['files_downloading']:
        return 0

    download_count = 0
    download_start_times = []

    visited = set()
    current_time = 0
    to_visit = [(0, 0, mComA)]
    heapify(to_visit)

    if mFileID == 111 and mTime == 55:
        pass

    while to_visit:
        current_time, current_dist, current_computer = heappop(to_visit)
        if current_computer in visited:
            continue
        visited.add(current_computer)
        if mFileID in computers[current_computer]['files_shared']:
            start_time = max(current_time, computers[mComA]['files_downloading'][mFileID], computers[current_computer]['files_shared'][mFileID])
            download_start_times.append(start_time)

        for neighbour in links[current_computer]:
            if neighbour in visited:
                continue
            new_dist = current_dist + links[current_computer][neighbour][1]
            new_time = max(current_time, links[current_computer][neighbour][0])
            if new_dist <= 5000:
                heappush(to_visit, (new_time, new_dist, neighbour))


    for download_start_time in download_start_times:
        download_count += (mTime - download_start_time) * 9

    if download_count >= files[mFileID]['size']:
        download_count = files[mFileID]['size']
        del computers[mComA]['files_downloading'][mFileID]
        computers[mComA]['files_downloaded'].add(mFileID)

    return download_count