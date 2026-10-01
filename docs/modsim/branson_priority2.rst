*******
Branson
*******

The Branson benchmark defines both Priority 1 and Priority 2 problems.
See the :doc:`Branson benchmark documentation
<../20_branson/branson>` for the benchmark description, build instructions,
run instructions, and problem definitions.

Problem
-------

Priority 2 problem is multi-node.  The ``inputs`` folder contains the 3D, 
load-balanced hohlraum input file for multi-node: ``3D_lb_holhraum.xml``
This input should also be run with a 30 group build of Branson, 
which is the default in the ats-6 branch.
The ``3D_lb_holhraum.xml`` problem is meant to run on multiple nodes.

It is run with:

.. code-block:: bash

   mpirun -n <devices_on_node> <install-location/BRANSON> <path/to/branson/inputs/3D_lb_hohlraum.xml>

..

For the multi-node problem, the ``particle_message_size`` value in the input is the main parameter
that will affect performance, especially on the GPU. Using a larger particle message size means that
more memory will be used in MPI buffers, which are statically sized to the particle message size and
allocated for each neighbor of a a domain. The memory used by MPI buffers on a rank is thus the
number of neighbors multiplied by the particle message size (which is in number of particles)
multiplied by the size of a particle.

Scaling on El Capitan
=====================
