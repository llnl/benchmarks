*******
Branson
*******

The Branson benchmark defines both Priority 1 and Priority 2 problems.
See the :doc:`Branson benchmark documentation
<../20_branson/branson>` for the benchmark description, build instructions,
run instructions, and problem definitions.

Problem
-------

For Priority 2, a homogeneous, multi-node, optically thick problem is weak scaled. The single node
input for four MPI ranks is the input file ``3D_homogeneous_1.xml`` in the ``inputs/weak_scaling``
folder. For two nodes, use the ``3D_homogeneous_2.xml`` file in the same folder and so on for larger
node counts. This problem is also run with a 30 group build of Branson. This simulation is
domain-decomposed, meaning MPI ranks will exchange particles as they move off domains. In this problem the number of
particles and cells are both increased in proportion to the computing resources. The input files
specify a number of subdomains (MPI ranks) in each dimension. The input files are for a node that
has 4 GPUs, but it can be changed to suit the parallel resources of any node by setting the
``n_x_domains``, ``n_y_domains``, or ``n_z_domains`` fields in the ``common`` block of the Branson
XML input file. The FOM for this problem will likely be much less than the single node input as
there is considerably more transport work and MPI messaging in this problem.
It is run with:

.. code-block:: bash

   mpirun -n <devices_on_node> <install-location/BRANSON> <path/to/branson/inputs/weak_scaling/3D_homogeneous_1.xml>

..
For the multi-node problem, the ``particle_message_size`` value in the input is the main parameter
that will affect performance, especially on the GPU. Using a larger particle message size means that
more memory will be used in MPI buffers, which are statically sized to the particle message size and
allocated for each neighbor of a a domain. The memory used by MPI buffers on a rank is thus the
number of neighbors multiplied by the particle message size (which has units of number of particles,
not bytes) multiplied by the size of a particle. The ``particle_message_size`` is set in the
``common`` block in the Branson XML input file.


Scaling on El Capitan
=====================
