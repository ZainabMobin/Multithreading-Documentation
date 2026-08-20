# Preemption Configuration Flags {#preempt_flags_page}

Auto-generated from `kernel/Kconfig.preempt`.


| Symbol | Label / Prompt | Description |
| :--- | :--- | :--- |
| `CONFIG_PREEMPT_NONE_BUILD` | *Internal / Derived* | N/A |
| `CONFIG_PREEMPT_VOLUNTARY_BUILD` | *Internal / Derived* | N/A |
| `CONFIG_PREEMPT_BUILD` | *Internal / Derived* | N/A |
| `CONFIG_ARCH_HAS_PREEMPT_LAZY` | *Internal / Derived* | N/A |
| `CONFIG_PREEMPT_NONE` | No Forced Preemption (Server) | This is the traditional Linux preemption model, geared towards throughput. It will still provide good latencies most of the time, but there are no guarantees and occasional longer delays are possible. |
| `CONFIG_PREEMPT_VOLUNTARY` | Voluntary Kernel Preemption (Desktop) | This option reduces the latency of the kernel by adding more "explicit preemption points" to the kernel code. These new preemption points have been selected to reduce the maximum latency of rescheduling, providing faster application reactions, at the cost of slightly lower throughput. |
| `CONFIG_PREEMPT` | Preemptible Kernel (Low-Latency Desktop) | This option reduces the latency of the kernel by making all kernel code (that is not executing in a critical section) preemptible.  This allows reaction to interactive events by permitting a low priority process to be preempted involuntarily even if it is in kernel mode executing a system call and would otherwise not be about to reach a natural preemption point. This allows applications to run more 'smoothly' even when the system is under load, at the cost of slightly lower throughput and a slight runtime overhead to kernel code. |
| `CONFIG_PREEMPT_LAZY` | Scheduler controlled preemption model | This option provides a scheduler driven preemption model that is fundamentally similar to full preemption, but is less eager to preempt SCHED_NORMAL tasks in an attempt to reduce lock holder preemption and recover some of the performance gains seen from using Voluntary preemption. |
| `CONFIG_PREEMPT_RT` | Fully Preemptible Kernel (Real-Time) | This option turns the kernel into a real-time kernel by replacing various locking primitives (spinlocks, rwlocks, etc.) with preemptible priority-inheritance aware variants, enforcing interrupt threading and introducing mechanisms to break up long non-preemptible sections. This makes the kernel, except for very low level and critical code paths (entry code, scheduler, low level interrupt handling) fully preemptible and brings most execution contexts under scheduler control. |
| `CONFIG_PREEMPT_RT_NEEDS_BH_LOCK` | Enforce softirq synchronisation on PREEMPT_RT | Enforce synchronisation across the softirqs context. On PREEMPT_RT the softirq is preemptible. This enforces the same per-CPU BLK semantic non-PREEMPT_RT builds have. This should not be needed because per-CPU locks were added to avoid the per-CPU BKL. |
| `CONFIG_PREEMPT_COUNT` | *Internal / Derived* | N/A |
| `CONFIG_PREEMPTION` | *Internal / Derived* | N/A |
| `CONFIG_PREEMPT_DYNAMIC` | Preemption behaviour defined on boot | This option allows to define the preemption model on the kernel command line parameter and thus override the default preemption model defined during compile time. |
| `CONFIG_SCHED_CORE` | Core Scheduling for SMT | This option permits Core Scheduling, a means of coordinated task selection across SMT siblings. When enabled -- see prctl(PR_SCHED_CORE) -- task selection ensures that all SMT siblings will execute a task from the same 'core group', forcing idle when no matching task is found. |
| `CONFIG_SCHED_CLASS_EXT` | Extensible Scheduling Class | This option enables a new scheduler class sched_ext (SCX), which allows scheduling policies to be implemented as BPF programs to achieve the following: |
