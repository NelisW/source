from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

extensions = [
    Extension("raysect.core.math._vec3", ["raysect/core/math/_vec3.pyx"]),
    Extension("raysect.core.math._mat4", ["raysect/core/math/_mat4.pyx"]),
    Extension("raysect.core.math.vector", ["raysect/core/math/vector.pyx"]),
    Extension("raysect.core.math.normal", ["raysect/core/math/normal.pyx"]),
    Extension("raysect.core.math.point", ["raysect/core/math/point.pyx"]),
    Extension("raysect.core.math.affinematrix", ["raysect/core/math/affinematrix.pyx"]),
    Extension("raysect.tests.speed_test_functions", ["raysect/tests/speed_test_functions.pyx"]),
    ]

setup(
    ext_modules = cythonize(extensions)
)