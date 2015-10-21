
# External imports
import matplotlib.pyplot as plt

# Raysect imports
from raysect.optical import World, translate, rotate, Point, d65_white, Ray
from raysect.optical.material import Lambert, schott, Checkerboard
from raysect.primitive import Sphere, Box
from raysect.core.math import Vector


# 1. Create Primitives
# --------------------

# Box defining the ground plane
ground = Box(lower=Point(-50, -1.51, -50), upper=Point(50, -1.5, 50), material=Lambert())

# checker board wall that acts as emitter
emitter = Box(lower=Point(-10, -10, 10), upper=Point(10, 10, 10.1),
              material=Checkerboard(4, d65_white, d65_white, 0.1, 2.0), transform=rotate(45, 0, 0))

# Sphere
# Note that the sphere must be displaced slightly above the ground plane to prevent numerically issues that could
# cause a light leak at the intersection between the sphere and the ground.
sphere = Sphere(radius=1.5, transform=translate(0, 0.0001, 0), material=schott("N-BK7"))


# 2. Add Observer
# ---------------

ray = Ray(origin=Point(0, 0, -5),
          direction=Vector(0, 0, 1),
          min_wavelength=375.0,
          max_wavelength=785.0,
          num_samples=100)


# 3. Build Scenegraph
# -------------------

world = World()

sphere.parent = world
ground.parent = world
emitter.parent = world


# 4. Observe()
# ------------

spectrum = ray.sample(world, 1000)

plt.plot(spectrum.wavelengths, spectrum.samples)
plt.show()
