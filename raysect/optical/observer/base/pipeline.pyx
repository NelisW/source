# cython: language_level=3

# Copyright (c) 2014-2016, Dr Alex Meakins, Raysect Project
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

cdef class Pipeline0D:
    """
    The base class for 0D pipelines.
    """

    cpdef object initialise(self, double min_wavelength, double max_wavelength, int spectral_bins, list spectral_slices, bint quiet):
        """
        Initialises containers for the pipeline's processing output.

        The deriving class should use this method to perform any initialisation needed
        for their calculations.

        This is a virtual method and must be implemented in a sub class.

        :param float min_wavelength: The minimum wavelength in the spectral range.
        :param float max_wavelength: The maximum wavelength in the spectral range.
        :param int spectral_bins: Number of spectral samples across wavelength range.
        :param list spectral_slices: List of spectral sub-ranges for cases where spectral
          rays is > 1 (i.e. dispersion effects turned on).
        :param bool quiet: When True, suppresses output to the terminal.
        """
        raise NotImplementedError("Virtual method must be implemented by a sub-class.")

    cpdef PixelProcessor pixel_processor(self, int slice_id):
        """
        Initialise and return a pixel processor for this pipeline.

        Called by worker threads, each worker will request a pixel processor for
        processing the output of their work from each pipeline.

        This is a virtual method and must be implemented in a sub class.

        :param int slice_id: The integer identifying the spectral slice being worked on
          by the requesting worker thread.
        :rtype: PixelProcessor
        """
        raise NotImplementedError("Virtual method must be implemented by a sub-class.")

    cpdef object update(self, int slice_id, tuple packed_result, int samples):
        """
        Updates the internal results array with packed results from the pixel processor.

        After worker threads have observed the world and used the pixel processor to
        process the spectra into packed results, the worker then passes the packed results
        to the pipeline with the update() method.

        If this pipeline implements some form of visualisation, update the visualisation
        at the end of this method.

        This is a virtual method and must be implemented in a sub class.

        :param int slice_id: The integer identifying the spectral slice being worked on
          by the worker thread.
        :param tuple packed_result: The tuple of results generated by this pipeline's
          PixelProcessor.
        :param int samples: The number of samples taken by the worker. Needed for ensuring
          accuracy of statistical errors when combining new samples with previous results.
        """
        raise NotImplementedError("Virtual method must be implemented by a sub-class.")

    cpdef object finalise(self):
        """
        Finalises the results when rendering has finished.

        This method is called when all workers have finished sampling and the results need
        to undergo any final processing.

        If this pipeline implements some form of visualisation, use this method to plot the
        final visualisation of results.

        This is a virtual method and must be implemented in a sub class.
        """
        raise NotImplementedError("Virtual method must be implemented by a sub-class.")


cdef class Pipeline1D:
    """
    The base class for 1D pipelines.
    """

    cpdef object initialise(self, tuple pixels, int pixel_samples, double min_wavelength, double max_wavelength, int spectral_bins, list spectral_slices, bint quiet):
        """
        Initialises containers for the pipeline's processing output.

        The deriving class should use this method to perform any initialisation needed
        for their calculations.

        This is a virtual method and must be implemented in a sub class.

        :param tuple pixels: A tuple defining the pixel dimensions being sampled
          (i.e. (256,)).
        :param int pixel_samples: The number of samples being taken per pixel. Needed
          for statistical calculations.
        :param float min_wavelength: The minimum wavelength in the spectral range.
        :param float max_wavelength: The maximum wavelength in the spectral range.
        :param int spectral_bins: Number of spectral samples across wavelength range.
        :param list spectral_slices: List of spectral sub-ranges for cases where spectral
          rays is > 1 (i.e. dispersion effects turned on).
        :param bool quiet: When True, suppresses output to the terminal.
        """
        raise NotImplementedError("Virtual method must be implemented by a sub-class.")

    cpdef PixelProcessor pixel_processor(self, int pixel, int slice_id):
        """
        Initialise and return a pixel processor for this pipeline and pixel coordinate.

        Called by worker threads, each worker will request a pixel processor for
        the pixel they are processing.

        This is a virtual method and must be implemented in a sub class.

        :param int pixel: The pixel coordinate of the pixel being sampled by the worker.
        :param int slice_id: The integer identifying the spectral slice being worked on
          by the requesting worker thread.
        :rtype: PixelProcessor
        """
        raise NotImplementedError("Virtual method must be implemented by a sub-class.")

    cpdef object update(self, int pixel, int slice_id, tuple packed_result):
        """
        Updates the internal results array with packed results from the pixel processor.

        After worker threads have observed the world and used the pixel processor to
        process the spectra into packed results, the worker then passes the packed results
        for the current pixel to the pipeline with the update() method. This method should
        add the results for this pixel to the pipeline's results array.

        If this pipeline implements some form of visualisation, update the visualisation
        at the end of this method.

        This is a virtual method and must be implemented in a sub class.

        :param int pixel: The integer identifying the pixel being worked on.
        :param int slice_id: The integer identifying the spectral slice being worked on
          by the worker thread.
        :param tuple packed_result: The tuple of results generated by this pipeline's
          PixelProcessor.
        """
        raise NotImplementedError("Virtual method must be implemented by a sub-class.")

    cpdef object finalise(self):
        """
        Finalises the results when rendering has finished.

        This method is called when all workers have finished sampling and the results need
        to undergo any final processing.

        If this pipeline implements some form of visualisation, use this method to plot the
        final visualisation of results.

        This is a virtual method and must be implemented in a sub class.
        """
        raise NotImplementedError("Virtual method must be implemented by a sub-class.")


cdef class Pipeline2D:
    """
    The base class for 2D pipelines.
    """

    cpdef object initialise(self, tuple pixels, int pixel_samples, double min_wavelength, double max_wavelength, int spectral_bins, list spectral_slices, bint quiet):
        """
        Initialises containers for the pipeline's processing output.

        The deriving class should use this method to perform any initialisation needed
        for their calculations.

        This is a virtual method and must be implemented in a sub class.

        :param tuple pixels: A tuple defining the pixel dimensions being sampled
          (i.e. (512, 512)).
        :param int pixel_samples: The number of samples being taken per pixel. Needed
          for statistical calculations.
        :param float min_wavelength: The minimum wavelength in the spectral range.
        :param float max_wavelength: The maximum wavelength in the spectral range.
        :param int spectral_bins: Number of spectral samples across wavelength range.
        :param list spectral_slices: List of spectral sub-ranges for cases where spectral
          rays is > 1 (i.e. dispersion effects turned on).
        :param bool quiet: When True, suppresses output to the terminal.          
        """
        raise NotImplementedError("Virtual method must be implemented by a sub-class.")

    cpdef PixelProcessor pixel_processor(self, int x, int y, int slice_id):
        """
        Initialise and return a pixel processor for this pipeline and pixel coordinate.

        Called by worker threads, each worker will request a pixel processor for
        the pixel they are currently processing.

        This is a virtual method and must be implemented in a sub class.

        :param int x: The x pixel coordinate (x, y) of the pixel being sampled by the worker.
        :param int y: The y pixel coordinate (x, y) of the pixel being sampled by the worker.
        :param int slice_id: The integer identifying the spectral slice being worked on
          by the requesting worker thread.
        :rtype: PixelProcessor
        """
        raise NotImplementedError("Virtual method must be implemented by a sub-class.")

    cpdef object update(self, int x, int y, int slice_id, tuple packed_result):
        """
        Updates the internal results array with packed results from the pixel processor.

        After worker threads have observed the world and used the pixel processor to
        process the spectra into packed results, the worker then passes the packed results
        for the current pixel to the pipeline with the update() method. This method should
        add the results for this pixel to the pipeline's results array.

        If this pipeline implements some form of visualisation, update the visualisation
        at the end of this method.

        This is a virtual method and must be implemented in a sub class.

        :param int x: The x pixel coordinate (x, y) of the pixel being sampled by the worker.
        :param int y: The y pixel coordinate (x, y) of the pixel being sampled by the worker.
        :param int slice_id: The integer identifying the spectral slice being worked on
          by the worker thread.
        :param tuple packed_result: The tuple of results generated by this pipeline's
          PixelProcessor.
        """
        raise NotImplementedError("Virtual method must be implemented by a sub-class.")

    cpdef object finalise(self):
        """
        Finalises the results when rendering has finished.

        This method is called when all workers have finished sampling and the results need
        to undergo any final processing.

        If this pipeline implements some form of visualisation, use this method to plot the
        final visualisation of results.

        This is a virtual method and must be implemented in a sub class.
        """
        raise NotImplementedError("Virtual method must be implemented by a sub-class.")
