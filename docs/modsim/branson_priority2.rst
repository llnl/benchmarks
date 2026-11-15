*******
Branson
*******

The Branson benchmark defines both Tier 1 and Tier 2 problems.
See the :doc:`Branson benchmark documentation
<../20_branson/branson>` for the benchmark description, build instructions,
run instructions, and problem definitions.

Problem
-------

For Tier 2, a homogeneous, multi-node, optically thick problem is weak scaled. The single node
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


For the multi-node problem, the ``particle_message_size`` value in the input is the main parameter
that will affect performance, especially on the GPU. Using a larger particle message size means that
more memory will be used in MPI buffers, which are statically sized to the particle message size and
allocated for each neighbor of a a domain. The memory used by MPI buffers on a rank is thus the
number of neighbors multiplied by the particle message size (which has units of number of particles,
not bytes) multiplied by the size of a particle. The ``particle_message_size`` is set in the
``common`` block in the Branson XML input file.


Baseline on El Capitan
======================


Performance Projection
======================

The Tier 2 weak scaling problem is the multi-node, domain-decomposed homogeneous
problem described in the :doc:`ModSim Tier 2 Branson page <../modsim/branson_priority2>`.
It weak scales the 3D homogeneous input, increasing the number of particles and cells in
proportion to the parallel resources so that the per-node workload is held fixed as the
node count grows.

To project Branson weak scaling performance for a Scalable Unit (SU), start from the
single-node baseline captured in :ref:`branson-baseline`. Select the per-node problem size
(photons per node) at the point where the single-node FOM saturates.
Keeping the number of groups fixed, scale the number of particles by the number of nodes in a
scalable unit. The number of total cells also needs to scale up in the same proportion, to do this
scale the x, y, and z dimensions, as well as the number of cells
in the x, y, and z dimensions to arrive at a total number of cells that is a factor of the number of
nodes in the SU larger than the single node run. Also scale the ``n_x_domains``,
``n_y_domains``, and ``n_z_domains`` fields so the domain decomposition matches the number
of GPUs in the SU and the scaling factor applied to each of those dimensions. An example of this
scale up can be seen by comparing the single node input to the 384 nodes input for the SU of El Cap
available in the branson inputs folder. The ``particle_message_size`` may be optimized at the SU
scale. Because the problem is weak scaled, the projected aggregate FOM (photons/second) for the SU
is the saturated single-node FOM multiplied by the number of nodes in the SU. Note that the
measured FOM will fall below this ideal projection due to the particle communication and MPI
messaging introduced by domain decomposition; the gap between the ideal and measured FOM
reflects the parallel efficiency of the weak scaling study.
