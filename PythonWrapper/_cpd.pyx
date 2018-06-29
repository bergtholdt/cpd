import numpy as np
cimport numpy as np  # for np.ndarray
from libc.string cimport memcpy
from libcpp.string cimport string
from eigency.core cimport ndarray_copy, ndarray

cdef class CPD:
    cdef cpd::Transform *trans
    cdef cpd::Matrix *fixed 
    cdef cpd::Matrix *moving 
    cdef cpd::Result result

    def __cinit__(self, fixed=np.ndarray[np.float32_t, ndim=2], moving=np.ndarray[np.float32_t, ndim=2]):
        self.fixed = fixed
        self.moving = moving        

    def __dealloc__(self):
        del self.trans
        del self.fixed
        del self.moving

    def rigid(reflections=False, scale=False):
        cdef rigid = new Rigid()
        rigid.scale(scale)
        rigid.reflections(reflections)
        del self.trans
        self.trans = rigid
        self.result = self.trans.run(self.fixed, self.moving)

    def affine(linked=True):
        cdef affine = new Affine()
        affine.linked(linked)
        del self.trans
        self.trans = affine
        self.result = self.trans.run(self.fixed, self.moving)

    property result:
        def __get__(self):
            cdef Json::Value val = cpd::to_json(self._trans.result)            
            cdef Json::StreamWriterBuilder builder
            cdef string res = Json::writeString(builder, val)
            return res

        # def __set__(self, args):
        #     fi = self._sys_geo_cpd
        #     old_size = self.size
        #     fi.nx, fi.ny, fi.nz = args
        #     if old_size != self.size:
        #         self._data.resize(self.size[::-1])
        #         self.data = self._data


