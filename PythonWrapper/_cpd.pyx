import numpy as np
cimport numpy as np  # for np.ndarray
from libc.string cimport memcpy
from libcpp.string cimport string
from eigency.core cimport ndarray_copy, ndarray, Map
#from _cpd cimport Transform, Matrix, Result, Value, get_json, Rigid, Affine, to_json
from _cpd cimport Transform, Matrix, Result, Rigid, Affine, Value, to_json, get_json

cdef class CPD:
    cdef np.ndarray _fixed
    cdef np.ndarray _moving 
    cdef Result _result

    def __cinit__(self, np.ndarray[np.float64_t, ndim=2, mode ='c'] fixed=None, np.ndarray[np.float64_t, ndim=2, mode ='c'] moving=None):
        if fixed is not None:
            self._fixed = fixed
        if moving is not None:
            self._moving = moving

    def rigid(self, reflections=False, scale=False):
        cdef Rigid rigid = Rigid()
        print(1)
        rigid.scale(scale)
        print(2)
        rigid.reflections(reflections)
        print(3)
        self._result = rigid.run(Map[Matrix](self._fixed),
                                 Map[Matrix](self._moving))
        print(4)

    def affine(self, linked=True):
        cdef Affine affine = Affine()
        affine.linked(linked)
        self._result = affine.run(Map[Matrix](self._fixed), Map[Matrix](self._moving))

    property fixed:
        def __get__(self):
            return self._fixed

        def __set__(self, np.ndarray[np.float64_t, ndim=2] fixed):
            self._fixed = fixed

    property moving:
        def __get__(self):
            return self._moving

        def __set__(self, np.ndarray[np.float64_t, ndim=2] moving):
            self._moving = moving

    property result:
        def __get__(self):
            cdef Value val = to_json(self._result)
            cdef string res = get_json(val)
            return res

        # def __set__(self, args):
        #     fi = self._sys_geo_cpd
        #     old_size = self.size
        #     fi.nx, fi.ny, fi.nz = args
        #     if old_size != self.size:
        #         self._data.resize(self.size[::-1])
        #         self.data = self._data


