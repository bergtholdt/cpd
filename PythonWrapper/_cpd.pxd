cimport numpy as np
import numpy as np
from libcpp.string cimport string
from libcpp.vector cimport vector
from eigency.core cimport MatrixXd as Matrix, Map
from eigency.core cimport VectorXd as Vector
from libcpp cimport bool

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

    cppclass Transform[T]:
        Transform& correspondence(bool correspondence) except +
        Transform& max_iterations(double max_iterations) except +
        Transform& normalize(bool normalize) except +
        Transform& outliers(double outliers) except +
        Transform& sigma2(double sigma2) except +
        Transform& tolerance(double tolerance) except +
        T run(Map[Matrix] fixed, Map[Matrix] moving) except +

cdef extern from "cpd/rigid.hpp" namespace "cpd":
    cppclass RigidResult(Result):
        pass
        
    cppclass Rigid(Transform[RigidResult]):
        Rigid()
        Rigid& reflections(bool reflections)
        Rigid& scale(bool scale)
        #RigidResult run(Matrix fixed, Matrix moving) except +

cdef extern from "cpd/affine.hpp" namespace "cpd":
    cppclass AffineResult(Result):
        pass

    cppclass Affine(Transform[AffineResult]):
        Affine()
        Affine& linked(bool linked)
        #AffineResult run(Matrix fixed, Matrix moving) except +

cdef extern from "cpd/nonrigid.hpp" namespace "cpd":
    cppclass NonrigidResult(Result):
        pass

    cppclass Nonrigid(Transform[NonrigidResult]):
        Nonrigid()
        Nonrigid& linked(bool linked)
        Nonrigid& beta(double beta)
        Nonrigid& c_lambda "lambda"(double lam)

cdef extern from "json/value.h" namespace "Json":
    cppclass Value:
        pass

cdef extern from "cpd_util.h" namespace "cpd":
    string get_json(Value)

cdef extern from "cpd/jsoncpp.hpp" namespace "cpd":
    Value to_json(Result result)
    Value to_json(RigidResult result)
    Value to_json(AffineResult result)
    Value to_json(NonrigidResult result)
    Value to_json(Matrix matrix)
    