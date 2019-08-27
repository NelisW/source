# cython: language_level=3

# Copyright (c) 2014-2018, Dr Alex Meakins, Raysect Project
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

cimport cython

@cython.cdivision(True)
cdef inline double cubic1d(double x0, double x1, double f0, double f1, double dfdx0, double dfdx1, double x) nogil:
    return ((f1 - f0) / (x1 - x0)) * (x - x0) + f0


cdef double cubic2d(double x0, double x1, double y0, double y1, double[:,:,::1] f,
                    double[:,:,::1] dfdx, double[:,:,::1] dfdy, double[:,:,::1] dfdxdy,
                    double x, double y) nogil


cdef double cubic3d(double x0, double x1, double y0, double y1, double z0, double z1, double[:,:,::1] f,
                    double[:,:,::1] dfdx, double[:,:,::1] dfdy, double[:,:,::1] dfdz,
                    double[:,:,::1] dfdxdy, double[:,:,::1] dfdxdz, double[:,:,::1] dfdydz,
                    double[:,:,::1] dfdxdydz, double x, double y, double z) nogil

