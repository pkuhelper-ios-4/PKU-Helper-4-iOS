#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# filename: utils.py

__all__ = [

    "mkdir",
    "json_load",
    "json_dump",
    "timeit",

    ]

import os
import platform
import time
from functools import wraps
import json
import matplotlib.pyplot as plt


def mkdir(path):
    if not os.path.exists(path):
        os.mkdir(path)

def json_load(file):
    with open(file, "r", encoding="utf-8") as fp:
        return json.load(fp)

def json_dump(obj, file):
    with open(file, "w", encoding="utf-8") as fp:
        json.dump(obj, fp, indent=4, ensure_ascii=False)

def timeit(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        name = func.__name__
        print("START %s" % name)
        t1 = time.time()
        res = func(*args, **kwargs)
        t2 = time.time()
        cost = t2 - t1
        print("%s cost %g s" % (name, cost))
        print("END %s" % name)
        return res
    return wrapper

def plt_maximize():
    # See discussion: https://stackoverflow.com/questions/12439588/how-to-maximize-a-plt-show-window-using-python
    backend = plt.get_backend()
    cfm = plt.get_current_fig_manager()
    if backend == "wxAgg":
        cfm.frame.Maximize(True)
    elif backend == "TkAgg":
        if platform.system() == "win32":
            cfm.window.state('zoomed')  # This is windows only
        else:
            cfm.resize(*cfm.window.maxsize())
    elif backend == 'QT4Agg':
        cfm.window.showMaximized()
    elif callable(getattr(cfm, "full_screen_toggle", None)):
        if not getattr(cfm, "flag_is_max", None):
            cfm.full_screen_toggle()
            cfm.flag_is_max = True
    else:
        raise RuntimeError("plt_maximize() is not implemented for current backend:", backend)
