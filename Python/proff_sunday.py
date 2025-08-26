days = {"MON": 6,
        "TUE": 5,
        "WED": 4,
        "THU": 3,
        "FRI": 2,
        "SAT": 1,
        "SUN": 7}

def solve(day: str) -> int:
    return days[day]