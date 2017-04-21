# cython: language_level=3

# Copyright (c) 2014-2017, Dr Alex Meakins, Raysect Project
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     1. Redistributions of source code must retain the above copyright notice,
#        this list of conditions and the following disclaimer.
#
#     2. Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in the
#        documentation and/or other materials provided with the distribution.
#
#     3. Neither the name of the Raysect Project nor the names of its
#        contributors may be used to endorse or promote products derived from
#        this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.


import numpy as np
cimport numpy as np

from raysect.core cimport Point2D, new_point2d
from raysect.core.math.cython cimport polygon_winding_2d
cimport cython


cpdef np.ndarray triangulate2d(np.ndarray vertices):
    """
    1) determine winding of polygon

    2) If polygon anti-clockwise, convert to clockwise.

    3) Loop through vertices

      3a) Identify if convex

      3b) Try triangle composed of neighbouring vertices, test every remaining
          vertex to see if they are enclosed by the triangle. If the triangle
          contains no vertices, it is an ear, add it to the list of triangles and
          remove vertex from list of trial

    4) Repeat 3) until only 3 vertices remain.


    :param vertices:
    :return:
    """

    cdef:
        list active_vertices
        int ear_index, i
        np.ndarray triangles

    vertices = np.array(vertices, dtype=np.float64)

    # validate shape of array
    if vertices.ndim != 2 or vertices.shape[1] != 2:
        raise ValueError("Vertex array must be an Nx2 array.")

    # ensure winding order is clockwise
    if not polygon_winding_2d(vertices):
        vertices = vertices[::-1, :]

    # active vertices stores index of the vertices that haven't yet been processed.
    active_vertices = list(range(vertices.shape[0]))

    # create array to hold output triangles
    triangles = np.empty((vertices.shape[0] - 2, 3), dtype=np.int32)

    i = 0
    while len(active_vertices) > 3:

        ear_index = _locate_ear(active_vertices, vertices)

        # store new triangle
        triangles[i, 0] = active_vertices[(ear_index - 1) % len(active_vertices)]
        triangles[i, 1] = active_vertices[ear_index]
        triangles[i, 2] = active_vertices[(ear_index + 1) % len(active_vertices)]

        i += 1

        # remove vertex from active vertex list
        active_vertices.pop(ear_index)

    # add the last triangle
    triangles[i, 0] = active_vertices[0]
    triangles[i, 1] = active_vertices[1]
    triangles[i, 2] = active_vertices[2]

    return triangles


cpdef int _locate_ear(list active_vertices, np.ndarray vertices) except -1:

    cdef:
        int ear_vertex, length, n, v1i, v2i, v3i, n_previous, n_next

    length = len(active_vertices)
    for n in range(length):

        n_previous = (n - 1) % length
        n_next = (n + 1) % length

        # obtain selected vertex indices and vertex coordinates
        v1i = active_vertices[n_previous]
        v1x = vertices[v1i, 0]
        v1y = vertices[v1i, 1]

        v2i = active_vertices[n]
        v2x = vertices[v2i, 0]
        v2y = vertices[v2i, 1]

        v3i = active_vertices[n_next]
        v3x = vertices[v3i, 0]
        v3y = vertices[v3i, 1]

        # non-convex points cannot be ears by definition
        if not _is_convex(v1x, v1y, v2x, v2y, v3x, v3y):
            continue

        # do any other vertex points lie inside the triangle formed by these three points
        for m in range(length):
            if m == n or m == n_previous or m == n_next:
                continue

            # obtain vertex index and coordinates of test point
            pi = active_vertices[m]
            px = vertices[pi, 0]
            py = vertices[pi, 1]

            if _inside_triangle(v1x, v1y, v2x, v2y, v3x, v3y, px, py):
                break
        else:
            # if code reaches here, n is the index of the first valid ear, since no points where inside triangle
            return n

    raise RuntimeError("Simple polygons must always have at least one ear, none were found."
                       "Please check the polygon data describes a simple polygon.")


cdef inline bint _is_convex(double v1x, double v1y, double v2x, double v2y, double v3x, double v3y) nogil:
    """
    Returns True if vertex is convex.
    """

    cdef double ux, uy, vx, vy

    # calculate vectors
    ux = v2x - v1x
    uy = v2y - v1y

    vx = v3x - v2x
    vy = v3y - v2y

    # calculate z component of cross product of vectors between vertices
    # vertex is convex if z component of u.cross(v) is negative
    return (ux * vy - vx * uy) < 0


cdef inline bint _inside_triangle(double v1x, double v1y, double v2x, double v2y,
                                  double v3x, double v3y, double px, double py) nogil:
    """Returns True if test point is inside triangle."""

    cdef:
        double ux, uy, vx, vy

    # calculate vectors
    ux = v2x - v1x
    uy = v2y - v1y

    vx = px - v1x
    vy = py - v1y

    # calculate z component of cross product of vectors between vertices
    # vertex is convex if z component of u.cross(v) is negative
    if (ux * vy - vx * uy) > 0:
        return False

    # calculate vectors
    ux = v3x - v2x
    uy = v3y - v2y

    vx = px - v2x
    vy = py - v2y

    # calculate z component of cross product of vectors between vertices
    # vertex is convex if z component of u.cross(v) is negative
    if (ux * vy - vx * uy) > 0:
        return False

    # calculate vectors
    ux = v1x - v3x
    uy = v1y - v3y

    vx = px - v3x
    vy = py - v3y

    # calculate z component of cross product of vectors between vertices
    # vertex is convex if z component of u.cross(v) is negative
    if (ux * vy - vx * uy) > 0:
        return False

    return True


# TODO - make proper tests
# In [4]: _locate_ear([Point2D(0, 0), Point2D(0, 1), Point2D(1, 1), Point2D(1, 0)])
# Out[4]: 0
# In [6]: _locate_ear([Point2D(0, 0), Point2D(0, 1), Point2D(1, 1), Point2D(0.01, 0.5), Point2D(1, 0)])
# Out[6]: 2
#
# In [7]: _locate_ear([Point2D(0, 0), Point2D(0, 1), Point2D(0.01, 0.5), Point2D(1, 0)])
# Out[7]: 1

# In [1]: from raysect.core.math.polygon import triangulate2d
#
# In [2]: import numpy as np
#
# In [3]: v = np.array([[0, 0], [0, 1], [1,1], [0.01, 0.5], [1, 0]])
#
# In [4]: triangulate2d(v)
# Out[4]:
# array([[1, 2, 3],
#        [0, 1, 3],
#        [0, 3, 4]], dtype=int32)

# In [3]: _inside_triangle(Point2D(0, 0), Point2D(1, 1), Point2D(1, 0), Point2D(1, 1))
# Out[3]: True
#
# In [4]: _inside_triangle(Point2D(0, 0), Point2D(1, 1), Point2D(1, 0), Point2D(0.5, 0.5))
# Out[4]: True
#
# In [5]: _inside_triangle(Point2D(0, 0), Point2D(1, 1), Point2D(1, 0), Point2D(0.5, 0.500000005))
# Out[5]: False

# In [2]: from raysect.core.math.polygon import _is_convex
#
# In [3]: _is_convex(Point2D(0, 0), Point2D(0, 1), Point2D(1, 0))
# Out[3]: True
#
# In [4]: _is_convex(Point2D(0, 0), Point2D(0, 1), Point2D(-1, 0))
# Out[4]: False
#
# In [5]: _is_convex(Point2D(0, 0), Point2D(0, -1), Point2D(1, 0))
# Out[5]: False
#
# In [6]: _is_convex(Point2D(0, 0), Point2D(0, -1), Point2D(1, -1))
# Out[6]: False
#
# In [7]: _is_convex(Point2D(0, 0), Point2D(0, -1), Point2D(-1, -1))
# Out[7]: True
#
# In [8]: _is_convex(Point2D(0, 0), Point2D(1, 1), Point2D(2, 2))
# Out[8]: False
#
# In [9]: _is_convex(Point2D(0, 0), Point2D(1, 1), Point2D(0, 0))
# Out[9]: False


