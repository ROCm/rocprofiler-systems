.. meta::
   :description: ROCm Systems Profiler documentation and reference
   :keywords: rocprof-sys, rocprofiler-systems, ROCm, profiler, tracking, visualization, tool, Instinct, accelerator, AMD

****************************************************
Configuring and validating the environment
****************************************************

After installing `ROCm Systems Profiler <https://github.com/ROCm/rocprofiler-systems>`_, additional steps are required to set up
and validate the environment.

.. note::

   The following instructions use the installation path ``/opt/rocprof-sys``. If
   ROCm Systems Profiler is installed elsewhere, substitute the actual installation path.

Configuring the environment
========================================

After ROCm Systems Profiler is installed, source the ``setup-env.sh`` script to prefix the
``PATH``, ``LD_LIBRARY_PATH``, and other environment variables:

.. code-block:: shell

   source /opt/rocprof-sys/share/rocprof-sys/setup-env.sh

Alternatively, if environment modules are supported, add the ``<prefix>/share/modulefiles`` directory
to ``MODULEPATH``:

.. code-block:: shell

   module use /opt/rocprof-sys/share/modulefiles

.. note::

   As an alternative, the above line can be added to the ``${HOME}/.modulerc`` file.

After ROCm Systems Profiler has been added to the ``MODULEPATH``, it can be loaded
using ``module load rocprof-sys/<VERSION>`` and unloaded using ``module unload rocprof-sys/<VERSION>``.

.. code-block:: shell

   module load rocprof-sys/1.0.0
   module unload rocprof-sys/1.0.0

.. note::

   You might also need to add the path to the ROCm libraries to ``LD_LIBRARY_PATH``,
   for example, ``export LD_LIBRARY_PATH=/opt/rocm/lib:${LD_LIBRARY_PATH}``

Validating the environment configuration
========================================

If the following commands all run successfully with the expected output,
then you are ready to use ROCm Systems Profiler:

.. code-block:: shell

   which rocprof-sys
   which rocprof-sys-avail
   which rocprof-sys-sample
   rocprof-sys-instrument --help
   rocprof-sys-avail --all
   rocprof-sys-sample --help

If ROCm Systems Profiler was built with Python support, validate these additional commands:

.. code-block:: shell

   which rocprof-sys-python
   rocprof-sys-python --help
