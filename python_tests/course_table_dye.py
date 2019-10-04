#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# filename: course_table_dye.py
'''
课程表染色算法
------------

1. 相邻课程染色不冲突
2. 输入数据源相同时，染色结果相同
3. 当周不显示的课程的颜色固定，且不与任何颜色冲突
4. 直接根据二维的渲染的效果来处理时间冲突的课程，重叠的课程可以拥有相同颜色

'''

import os
import sys
import time
import hashlib
from pprint import pprint
from collections import defaultdict
from itertools import product
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from matplotlib.font_manager import FontProperties
from utils import mkdir, json_load, timeit, plt_maximize

matplotlib.use("Qt4Agg") # pip3 install pyqt5


LOG_DIR = "./log"
mkdir(LOG_DIR)

LOG_FILE = "./log/course_table_dye.log"
DEFAULT_COURSE_TABLE_V2_JSON = "./data/course_table_v2_19-20_1.json"

MAX_SEED_FOR_RANDOM = 2**32
ADDITIONAL_SEED_FOR_RANDOM = 0

ROW = 12
COLUMN = 7
CURRENT_WEEK = 4

SPECIFIC_WEEKS = frozenset( str(week) for week in range(19) ) # 0 - 18
HOLIDAY_WEEK = 0

MIN_LESSON = 1
MAX_LESSON = ROW
MIN_WEEKDAY = 1
MAX_WEEKDAY = COLUMN

NULL_COURSE_INDEX = -1

DEFAULT_COLOR_POOL_SIZE = 3
COLOR_INDEX_FOR_HIDDEN_CLASS = 0
NULL_COLOR_INDEX = -1

COLOR_POOL = list(map(
    mcolors.CSS4_COLORS.__getitem__,
    [
        "lightgray", # color for hidden class

        "deepskyblue", "orange", "gold", "limegreen",
        "cornflowerblue", "violet", "hotpink", "mediumturquoise",
        "sandybrown", "lightcoral", "palegreen", "tan",

        *(["deepskyblue"] * 1000), # make sure this color pool is big enough

        "white", # color for null class
    ]
))

COLOR_FOR_HIDDEN_CLASS = COLOR_POOL[-1]

PLT_FONT = FontProperties(fname="/Library/Fonts/Songti.ttc") # in MacOS

fout = None  # lazy init


def _is_hidden_class(week, startWeek, endWeek):
    if startWeek > CURRENT_WEEK or endWeek < CURRENT_WEEK:
        return True
    if week == "每周":
        return False
    elif week == "单周":
        return CURRENT_WEEK % 2 != 1
    elif week == "双周":
        return CURRENT_WEEK % 2 != 0
    else:
        assert week in SPECIFIC_WEEKS, week
        iWeek = int(week)
        if iWeek == HOLIDAY_WEEK:
            return True
        else:
            return iWeek != CURRENT_WEEK


def parse_classes_from_course_table_v2_json(file=DEFAULT_COURSE_TABLE_V2_JSON):
    courseJSON = json_load(file)

    classes = [] # (weekday, start, end, isHidden, name)
    for course in courseJSON:
        name = course["name"]
        for clazz in course["classes"]:
            weekday, start, end, week, startWeek, endWeek = \
                map(clazz.__getitem__, ["weekday","start","end","week","start_week","end_week"])

            isHidden = _is_hidden_class(week, startWeek, endWeek)

            classes.append( (weekday, start, end, isHidden, name) )

    # classes.sort(key=lambda x: (x[4], x[0], x[1], x[2]))
    classes.sort()

    return classes


def _debug_print_classes(classes):
    courseTable = np.full(
        (ROW, COLUMN), # (lesson-1, weekday-1)
        '',
    )

    for weekday, start, end, isHidden, name in classes:
        if isHidden:
            continue
        for lesson in range(start, end + 1):
            courseTable[lesson-1, weekday-1] = name

    pprint(courseTable)


def _get_adjacency_indexs(weekday, start, end):
    indexs = [] # (weekday, lesson)

    #
    # Don't include indexes in situ, so that conflicted classes can have same color.
    #
    # indexs.extend([ (weekday, lesson) for lesson in range(start, end+1) ])

    if start > MIN_LESSON:
        indexs.append( (weekday, start - 1) )

    if end < MAX_LESSON:
        indexs.append( (weekday, end + 1) )

    if weekday > MIN_WEEKDAY:
        indexs.extend([ (weekday - 1, lesson) for lesson in range(start, end + 1) ])

    if weekday < MAX_WEEKDAY:
        indexs.extend([ (weekday + 1, lesson) for lesson in range(start, end + 1) ])

    return indexs


def get_adjacency_matrix(classes):

    # z-axis for overlap classes
    courseTable = np.full(
        (len(classes), ROW, COLUMN), # (cIndex, lesson-1, weekday-1)
        NULL_COURSE_INDEX,
        dtype=np.int8,
    )

    for cIndex, (weekday, start, end, isHidden, _) in enumerate(classes):
        if isHidden:
            continue
        for lesson in range(start, end+1):
            courseTable[cIndex, lesson-1, weekday-1] = cIndex

    matrix = np.zeros(
        (len(classes), len(classes)), # (cIndex, adjCIndex)
        dtype=np.bool,
    )

    for cIndex, (weekday, start, end, isHidden, _) in enumerate(classes):
        if isHidden:
            continue
        for adjWeekday, adjLesson in _get_adjacency_indexs(weekday, start, end):
            for adjCIndex in courseTable[:, adjLesson-1, adjWeekday-1]:
                if adjCIndex == NULL_COURSE_INDEX:
                    continue
                matrix[cIndex, adjCIndex] = matrix[adjCIndex, cIndex] = True

    return matrix

def get_adjacency_table_from_adjacency_matrix(adjacencyMatrix):

    classesCount = adjacencyMatrix.shape[0]

    table = [ [] for _ in range(classesCount) ]

    for cIndex, _cIndex in np.argwhere( adjacencyMatrix == True ):
        table[cIndex].append(_cIndex)

    return table

def _debug_print_adjacency_matrix(adjacencyMatrix):
    pprint(adjacencyMatrix.astype(np.int8))


def _debug_print_adjacency_classes(adjacencyMatrix, classes):
    res = { name: [] for name in [ item[4] for item in classes ] }

    for cIndex, adjCIndex in np.argwhere(adjacencyMatrix == True):
        res[classes[cIndex][-1]].append(classes[adjCIndex][-1])

    pprint(dict(res))


def get_constraint_matrix(classes):

    courses = defaultdict(lambda: []) # name -> cIndex

    for cIndex, (_, _, _, isHidden, name) in enumerate(classes):
        if isHidden:
            continue
        courses[name].append(cIndex)

    matrix = np.zeros(
        (len(classes), len(classes)), # (cIndex1, cIndex2)
        dtype=np.bool,
    )

    for name, cIndexes in courses.items():
        for cIndex1, cIndex2 in product(cIndexes, cIndexes):
            matrix[cIndex1, cIndex2] = True

    return matrix

def get_constraint_table_from_constraint_matrix(constraintMatrix):

    classesCount = constraintMatrix.shape[0]

    table = [ [] for _ in range(classesCount) ]

    for cIndex, _cIndex in np.argwhere( constraintMatrix == True ):
        table[cIndex].append(_cIndex)

    return table

def _hash_code_of_string(s):
    bDigest = hashlib.md5(s.encode("utf-8")).digest()
    return sum( x << i for i, x in enumerate(bytearray(bDigest)) )


def _get_color_indexes(classes, color_pool_size):
    startIndex = COLOR_INDEX_FOR_HIDDEN_CLASS + 1
    defaultColorIndexs = np.arange(startIndex, color_pool_size + startIndex)

    indexes = [ defaultColorIndexs.copy() for _ in range(len(classes)) ] # cIndex -> colorIndexes

    for cIndex, (_, _, _, _, name) in enumerate(classes):
        seed = (_hash_code_of_string(name) + ADDITIONAL_SEED_FOR_RANDOM * (cIndex + 1)) % MAX_SEED_FOR_RANDOM
        np.random.seed(seed)

        colorIndex = indexes[cIndex]
        np.random.shuffle(colorIndex)

    return indexes

#
# 通过优化遍历顺序来保证算法的效率
#
# 1. 从相邻课程数最多的课开始尝试
# 2. 如果
#

def _get_traversal_order(adjacencyMatrix, constraintTable):
    '''
    优化课程的遍历顺序
    ------------------
    这一步是算法效率优化的关键

    1. 按相邻课程数从多到少的顺序进行尝试染色
    2. 在 (1) 中课程确定了一个颜色后，优先对与其相邻的课程进行尝试染色
    3. 在 (1)(2) 中课程确定了一个颜色后，优先对与其课名相同的所有其他课进行尝试染色

    '''
    classesCount = adjacencyMatrix.shape[0]

    status = np.zeros(classesCount, dtype=np.bool)
    traversalOrder = np.full(
        classesCount + 1, # traversalOrder[-1] == NULL_COURSE_INDEX, flag of ending
        NULL_COURSE_INDEX,
        dtype=np.int8
    )

    adjCounts = adjacencyMatrix.sum(axis=0)
    testOrder = [ cIndex for (cIndex, _) in sorted(enumerate(adjCounts), key=lambda iv: iv[1], reverse=True) ]
    print(adjCounts)
    print(testOrder)

    idx = 0

    def _set_cIndex_at_current_idx(cIndex):
        nonlocal idx
        traversalOrder[idx] = cIndex
        idx += 1
        status[cIndex] = True
        for _cIndex in constraintTable[cIndex]:
            if status[_cIndex]:
                continue
            traversalOrder[idx] = _cIndex
            idx += 1
            status[_cIndex] = True

    for cIndex in testOrder:
        if status[cIndex]:
            continue
        _set_cIndex_at_current_idx(cIndex)
        if idx == classesCount:
            break

        for _cIndex in testOrder:
            if status[_cIndex]:
                continue
            if not adjacencyMatrix[cIndex, _cIndex]:
                continue
            _set_cIndex_at_current_idx(_cIndex)
            if idx == classesCount:
                break

    return traversalOrder


@timeit
def solve(classes, color_pool_size=DEFAULT_COLOR_POOL_SIZE, outermost=True):

    adjacencyMatrix = get_adjacency_matrix(classes)
    adjacencyTable = get_adjacency_table_from_adjacency_matrix(adjacencyMatrix)
    constraintMatrix = get_constraint_matrix(classes)
    constraintTable = get_constraint_table_from_constraint_matrix(constraintMatrix)

    # _debug_print_adjacency_classes(adjacencyMatrix, classes)
    # _debug_print_adjacency_matrix(adjacencyMatrix)
    pprint(adjacencyTable)

    # pprint(constraintMatrix.astype(np.int8))
    pprint(constraintTable)

    colorIndexes = _get_color_indexes(classes, color_pool_size)
    traversalOrder = _get_traversal_order(adjacencyMatrix, constraintTable)

    result = np.full(len(classes), NULL_COLOR_INDEX) # cIndex -> colorIndex


    def _is_conflicted(cIndex, colorIndex):
        for _cIndex, _colorIndex in enumerate(result):
            if _colorIndex == NULL_COLOR_INDEX:
                continue
            if _colorIndex == COLOR_INDEX_FOR_HIDDEN_CLASS: # hidden class, no conflict
                continue
            if constraintMatrix[cIndex, _cIndex]: # same course, no conflict
                continue
            print(cIndex, _cIndex, adjacencyMatrix[cIndex, _cIndex], _colorIndex, colorIndex, file=fout)
            if adjacencyMatrix[cIndex, _cIndex] and colorIndex == _colorIndex: # conflict
                return True
        return False

    def _recursively_dye(currentIndex):
        cIndex = traversalOrder[currentIndex]
        if cIndex == NULL_COURSE_INDEX:
            return True

        _, _, _, isHidden, _ = classes[cIndex]
        print(cIndex, classes[cIndex], file=fout)

        if isHidden:
            result[cIndex] = COLOR_INDEX_FOR_HIDDEN_CLASS # no reset
            return _recursively_dye(currentIndex + 1)

        for _cIndex in constraintTable[cIndex]:
            colorIndex = result[_cIndex]

            if colorIndex == NULL_COLOR_INDEX:
                continue
            if _is_conflicted(cIndex, colorIndex):
                return False

            result[cIndex] = colorIndex
            if _recursively_dye(currentIndex + 1):
                return True

            result[cIndex] = NULL_COLOR_INDEX # reset result
            return False

        for colorIndex in colorIndexes[cIndex]:
            if _is_conflicted(cIndex, colorIndex):
                continue

            result[cIndex] = colorIndex
            if _recursively_dye(currentIndex + 1):
                return True

            result[cIndex] = NULL_COLOR_INDEX # reset result

        return False

    if _recursively_dye(0):
        return result, color_pool_size
    else:
        # try larger color pool
        result, actual_color_pool_size = solve.__wrapped__(classes, color_pool_size + 1, False)
        if outermost:
            for idx, colorIndex in enumerate(result):
                if colorIndex == COLOR_INDEX_FOR_HIDDEN_CLASS:
                    continue
                if colorIndex <= color_pool_size:
                    continue
                actualColorIndex = colorIndex % color_pool_size
                if actualColorIndex == COLOR_INDEX_FOR_HIDDEN_CLASS:
                    result[idx] = COLOR_INDEX_FOR_HIDDEN_CLASS + color_pool_size
                else:
                    result[idx] = actualColorIndex
        return result, actual_color_pool_size


def _can_solved(result):
    return not any( x == NULL_COLOR_INDEX for x in result )


def _debug_print_result(result, classes):
    courseTable = np.full(
        (ROW, COLUMN), # (lesson-1, weekday-1)
        NULL_COLOR_INDEX,
        dtype=np.int8,
    )

    for cIndex, (weekday, start, end, _, _) in enumerate(classes):
        for lesson in range(start, end+1):
            courseTable[lesson-1, weekday-1] = result[cIndex]

    pprint(courseTable)


def _debug_show_course_table(result, classes):
    # (lesson-1, weekday-1)
    courseTable = [ [ '' for c in range(COLUMN) ] for r in range(ROW) ]
    colors = [ [ COLOR_FOR_HIDDEN_CLASS for c in range(COLUMN) ] for r in range(ROW) ]

    for cIndex, (weekday, start, end, _, name) in enumerate(classes):
        for lesson in range(start, end + 1):
            if colors[lesson-1][weekday-1] == COLOR_FOR_HIDDEN_CLASS:
                courseTable[lesson-1][weekday-1] = name
                colors[lesson-1][weekday-1] = COLOR_POOL[result[cIndex]]

    fig, ax = plt.subplots()

    fig.patch.set_visible(False)
    ax.axis('off')
    ax.axis('tight')

    table = ax.table(
        cellText=courseTable,
        cellColours=colors,
        rowLabels=list(range(1, ROW+1)),
        colLabels=list(range(1, COLUMN+1)),
        cellLoc='center',
        rowLoc='center',
        loc='center',
    )

    table.auto_set_font_size(False)
    table.set_fontsize(14)

    for cell in table.get_celld().values():
        cell.set_text_props(FontProperties=PLT_FONT)

    fig.tight_layout()
    plt_maximize()
    plt.show()


def task_single_solve(file=DEFAULT_COURSE_TABLE_V2_JSON, color_pool_size=DEFAULT_COLOR_POOL_SIZE):
    classes = parse_classes_from_course_table_v2_json(file)
    result, actualColorPoolSize = solve(classes, color_pool_size)

    print("size: (%s, %s)" % (color_pool_size, actualColorPoolSize))
    print(result)
    _debug_print_classes(classes)
    _debug_print_result(result, classes)
    _debug_show_course_table(result, classes)


def task_batch_solve():

    MIN_COLOR_POOL_SIZE = 1
    MAX_COLOR_POOL_SIZE = 64

    files = [
        "./data/course_table_v2_17-18_1.json",
        "./data/course_table_v2_17-18_2.json",
        "./data/course_table_v2_17-18_3.json",
        "./data/course_table_v2_18-19_1.json",
        "./data/course_table_v2_18-19_2.json",
        "./data/course_table_v2_18-19_3.json",
        "./data/course_table_v2_19-20_1.json",

        "./data/course_table_v2_full.json",
        "./data/course_table_v2_conflicted.json",
    ]

    for file in files:
        print(os.path.basename(file))
        classes = parse_classes_from_course_table_v2_json(file)

        for colorPoolSize in range(MIN_COLOR_POOL_SIZE, MAX_COLOR_POOL_SIZE + 1):
            print("size: %2d" % colorPoolSize, end="  ")

            t1 = time.time()
            result, actualColorPoolSize = solve.__wrapped__(classes, colorPoolSize)
            t2 = time.time()
            cost = t2 - t1
            print("cost: %9.6f" % cost, end="  ")

            if actualColorPoolSize > colorPoolSize:
                print("actual size: %s" % actualColorPoolSize, end="  ")

            print(result)


def task_solve_full():
    file = "./data/course_table_v2_full.json"
    task_single_solve(file)


def task_solve_conflicted():
    file = "./data/course_table_v2_conflicted.json"
    task_single_solve(file)


def main():
    # task_single_solve()
    # task_batch_solve()
    task_solve_full()
    # task_solve_conflicted()


if __name__ == "__main__":
    # fout = open(LOG_FILE, "w", encoding="utf-8")
    # fout = open(os.devnull, "w", encoding="utf-8")
    with open(LOG_FILE, "w", encoding="utf-8") as fp:
        fout = fp
        main()
