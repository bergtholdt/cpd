import numpy as np
cimport numpy as np  # for np.ndarray
from libc.string cimport memcpy
from libcpp.string cimport string
from eigency.core cimport ndarray_copy, ndarray, Map
#from _cpd cimport Transform, Matrix, Result, Value, get_json, Rigid, Affine, to_json
from _cpd cimport Transform, Matrix, Result, Rigid, Nonrigid, RigidResult, NonrigidResult, AffineResult, Affine, Value, to_json, get_json
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

    def rigid(self, reflections=None, scale=None):
        cdef Rigid rigid = Rigid()
        if reflections is not None:
            rigid.reflections(reflections)
        if scale is not None:
            rigid.scale(scale)
        cdef RigidResult res = rigid.run(Map[Matrix](self._fixed),
                                 Map[Matrix](self._moving))
        cdef Value val = to_json(res)
        cdef string result = get_json(val)
        return json.loads(result)

    def affine(self, linked=None):
        cdef Affine affine = Affine()
        if linked is not None:
            affine.linked(linked)
        cdef AffineResult res = affine.run(Map[Matrix](self._fixed), Map[Matrix](self._moving))
        cdef Value val = to_json(res)
        cdef string result = get_json(val)
        return json.loads(result)

    def nonrigid(self, linked=None, beta=None, lambda=None):
        cdef Nonrigid nonrigid = Nonrigid()
        if linked is not None:
            nonrigid.linked(linked)
        if beta is not None:
            nonrigid.beta(beta)
        if lambda is not None:
            nonrigid.c_lambda(lambda)
        cdef NonrigidResult res = nonrigid.run(Map[Matrix](self._fixed), Map[Matrix](self._moving))
        cdef Value val = to_json(res)
        cdef string result = get_json(val)
        return json.loads(result)

    property fixed:
        def __get__(self):
            return self._fixed

        def __set__(self, np.ndarray[np.float64_t, ndim=2] fixed):
            assert fixed.shape[0] == 3, "Fixed must be a 3xM matrix"
            self._fixed = fixed

    property moving:
        def __get__(self):
            return self._moving

        def __set__(self, np.ndarray[np.float64_t, ndim=2] moving):
            assert moving.shape[0] == 3, "Moving must be a 3xN matrix"
            self._moving = moving

        # def __set__(self, args):
        #     fi = self._sys_geo_cpd
        #     old_size = self.size
        #     fi.nx, fi.ny, fi.nz = args
        #     if old_size != self.size:
        #         self._data.resize(self.size[::-1])
        #         self.data = self._data


