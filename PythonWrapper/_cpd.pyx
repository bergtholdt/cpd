import numpy as np
cimport numpy as np  # for np.ndarray
from libc.string cimport memcpy
from libcpp.string cimport string
from eigency.core cimport ndarray_copy, ndarray, Map
#from _cpd cimport Transform, Matrix, Result, Value, get_json, Rigid, Affine, to_json
from _cpd cimport Transform, Matrix, Result, Rigid, RigidResult, AffineResult, Affine, Value, to_json, get_json
import json

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
        rigid.scale(scale)
        rigid.reflections(reflections)
        cdef RigidResult res = rigid.run(Map[Matrix](self._fixed),
                                 Map[Matrix](self._moving))
        cdef Value val = to_json(res)
        cdef string result = get_json(val)
        return json.loads(result)

    def affine(self, linked=True):
        cdef Affine affine = Affine()
        affine.linked(linked)
        cdef AffineResult res = affine.run(Map[Matrix](self._fixed), Map[Matrix](self._moving))
        cdef Value val = to_json(res)
        cdef string result = get_json(val)
        return json.loads(result)

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

        # def __set__(self, args):
        #     fi = self._sys_geo_cpd
        #     old_size = self.size
        #     fi.nx, fi.ny, fi.nz = args
        #     if old_size != self.size:
        #         self._data.resize(self.size[::-1])
        #         self.data = self._data


