# https://www.dexterindustries.com
#
# Copyright (c) 2019 Dexter Industries
# Released under the MIT license (http://choosealicense.com/licenses/mit/).
# For more information see https://github.com/DexterInd/DI_Sensors/blob/master/LICENSE.md
#
# Python mutex

import time
import fcntl
import os
import atexit
import threading


class DI_Mutex(object):
    """ Dexter Industries mutex """

    def __init__(self, name, loop_time = 0.0001):
        """ Initialize """

        self.Filename = "/run/lock/DI_Mutex_" + name
        self.LoopTime = loop_time
        self._local = threading.local()  # thread-local storage for file handle
        self._thread_lock = threading.RLock()  # intra-process: fcntl locks are per-process, not per-thread

        try:
            open(self.Filename, 'w').close()
            if os.path.isfile(self.Filename):
                os.chmod(self.Filename, 0o777)
        except Exception:
            pass

        # Register the exit method
        atexit.register(self.__exit_cleanup__) # register the exit method

    def __exit_cleanup__(self):
        """ Called at exit to clean up """

        self.release()

    def acquire(self):
        """ Acquire the mutex """

        self._thread_lock.acquire()  # block other threads in this process first
        while True:
            try:
                self._local.handle = open(self.Filename, 'w')
                # lock
                fcntl.lockf(self._local.handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
                return
            except OSError: # already locked by a different process
                time.sleep(self.LoopTime)
            except Exception as e:
                print(e)

    def release(self):
        """ Release the mutex """

        handle = getattr(self._local, 'handle', None)
        if handle is not None:
            handle.close()
            self._local.handle = None
            time.sleep(self.LoopTime)
            self._thread_lock.release()  # unblock waiting threads
