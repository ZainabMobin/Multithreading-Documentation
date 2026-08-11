#!/bin/bash
# Doxygen Kernel Filter - Normalizes kernel-doc @ tags to avoid parser crashes 
# misinterpreted as commands), multi-line comments from bleeding into function return types
# Writes modified code to stdout (required by Doxygen)
# Solves macro bleeding, missing variables, kernel-doc syntax, and unclosed blocks.

# cat "$1" | perl -pe '
#   if (m|^\s*[*//]|) {
#     # Replace @param_name with \param param_name or escape isolated @ words
#     s/@([a-zA-Z0-9_]+)/\x5Cparam $1/g;
#   }
# '

if [ ! -f "$1" ]; then
    exit 0
fi

perl -0777 -pe '
  # KERNEL-DOC & TAG NORMALIZATION

  # Transform kernel-doc @param_name tags to \param param_name strictly within comments
  s/(\/\*.*?\*\/)/ my $c = $1; $c =~ s\/@([a-zA-Z0-9_]+)\/\\param $1\/g; $c /seg;


  # SCHED.H & TASK FLAG MACRO EXPANSIONS (Fixes macro return-type bleeding)
  
  # Convert TASK_PFA_* macro generators into explicit function declarations terminated with semicolons
  s/TASK_PFA_TEST\s*\(\s*([A-Za-z0-9_]+)\s*,\s*([A-Za-z0-9_]+)\s*\)/bool task_$2(struct task_struct *p);/g;
  s/TASK_PFA_SET\s*\(\s*([A-Za-z0-9_]+)\s*,\s*([A-Za-z0-9_]+)\s*\)/void task_set_$2(struct task_struct *p);/g;
  s/TASK_PFA_CLEAR\s*\(\s*([A-Za-z0-9_]+)\s*,\s*([A-Za-z0-9_]+)\s*\)/void task_clear_$2(struct task_struct *p);/g;

  # Convert PER_TASK_COMM_LEN and array generators
  s/TASK_PFA_FAILSAFE\s*\([^)]*\)/;/g;


  #VARIABLE & SYMBOL EXTRACTION PRESERVATION

  # Strip attributes that obscure variable and function signatures
  s/__randomize_layout//g;
  s/__cacheline_aligned//g;
  s/____cacheline_aligned//g;
  s/__read_mostly//g;
  s/__ro_after_init//g;

  # Transform DECLARE_PER_CPU and DEFINE_PER_CPU into standard declarations so variables pass through
  s/DECLARE_PER_CPU\s*\(\s*([^,]+)\s*,\s*([^)]+)\s*\)/$1 $2;/g;
  s/DEFINE_PER_CPU\s*\(\s*([^,]+)\s*,\s*([^)]+)\s*\)/$1 $2;/g;

  # Convert struct_group macros inline so enclosed struct members are extracted as valid variables
  s/__struct_group\s*\([^,]*,\s*([^,]*),\s*[^,]*,\s*(.*?)\)/$2/gs;
  s/struct_group\s*\(\s*([^,]*),\s*(.*?)\)/$2/gs;


  # BOUNDARY SEPARATION & SANITATION
  
  # Force structural separation after comment blocks before function/variable keywords
  s/(\*\/)\s*(?=(?:static|inline|extern|unsigned|void|int|long|struct|enum|union|SYSCALL_DEFINE))/$1\n\n/g;

  # Eliminate un-semicoloned tracepoint macro invocations
  s/\b(?:TRACE_EVENT|DEFINE_EVENT|DECLARE_TRACE)\s*\([^)]*\)\s*;/;/g;

' "$1"