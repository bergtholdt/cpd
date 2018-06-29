cimport numpy as np
import numpy as np
from libcpp.string cimport string
from libcpp.vector cimport vector
from eigency.core cimport MatrixXd as Matrix
from eigency.core cimport VectorXd as Vector


# For Buffer usage
cdef extern from "Python.h":
    ctypedef struct PyObject
    object PyMemoryView_FromBuffer(Py_buffer *view)
    int PyBuffer_FillInfo(Py_buffer *view, PyObject *obj, void *buf, Py_ssize_t len, int readonly, int infoflags)
    enum:
        PyBUF_FULL_RO

cdef extern from "cpd/transform.hpp" namespace "cpd":
    cppclass Result:
        Matrix points;

    cppclass Transform:
        Transform& correspondence(bool correspondence) except +
        Transform& max_iterations(double max_iterations) except +
        Transform& normalize(bool normalize) except +
        Transform& outliers(double outliers) except +
        Transform& sigma2(double sigma2) except +
        Transform& tolerance(double tolerance) except +
        Result run(Matrix fixed, Matrix moving) except +

cdef extern from "cpd/rigid.hpp" namespace "cpd":
    cppclass RigidResult:
        pass
        
    cppclass Rigid:
        Rigid& reflections(bool reflections)
        Rigid& scale(bool scale)

cdef extern from "cpd/affine.hpp" namespace "cpd":
    cppclass AffineResult:
        pass

    cppclass Affine:
        Affine& linked(bool linked)

cdef extern from "cpd/nonrigid.hpp" namespace "cpd":
    cppclass NonrigidResult:
        pass

    cppclass Nonrigid:
        Nonrigid& beta(double beta)
        Nonrigid& lambda(double lambda)

cdef extern from "json/value.h" namespace "Json":
    cppclass Value:
        pass

cdef extern from "cpd/jsoncpp.hpp" namespace "cpd":
    Json::Value to_json(Result result)
    Json::Value to_json(RigidResult result)
    Json::Value to_json(AffineResult result)
    Json::Value to_json(NonrigidResult result)
    Json::Value to_json(Matrix matrix)
    