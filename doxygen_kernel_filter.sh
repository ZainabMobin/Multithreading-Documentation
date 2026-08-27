#!/bin/bash
# Doxygen Kernel Filter - Normalizes kernel-doc tags to standard comment text

if [ ! -f "$1" ]; then
    exit 0
fi

perl -0777 -pe '
  # 1. STRUCT & FUNCTION COMMENTS: Strip field tags (@member:, @param, \param)
  # Removes the tag commands completely so Doxygen treats it as plain doc text
  s/(\/\*\*?[\s\S]*?\*\/)/
    my $c = $1;
    $c =~ s\/\\param\s+([a-zA-Z0-9_]+):?\s*\/$1: \/g;
    $c =~ s\/\@([a-zA-Z0-9_]+):?\s*\/$1: \/g;
    $c;
  /ge;

  # 2. SCHED.H & TASK FLAG MACRO EXPANSIONS
  s/TASK_PFA_TEST\s*\(\s*([A-Za-z0-9_]+)\s*,\s*([A-Za-z0-9_]+)\s*\)/bool task_$2(struct task_struct *p);/g;
  s/TASK_PFA_SET\s*\(\s*([A-Za-z0-9_]+)\s*,\s*([A-Za-z0-9_]+)\s*\)/void task_set_$2(struct task_struct *p);/g;
  s/TASK_PFA_CLEAR\s*\(\s*([A-Za-z0-9_]+)\s*,\s*([A-Za-z0-9_]+)\s*\)/void task_clear_$2(struct task_struct *p);/g;
  s/TASK_PFA_FAILSAFE\s*\([^)]*\)/;/g;

  # 3. VARIABLE & SYMBOL EXTRACTION PRESERVATION
  s/__randomize_layout//g;
  s/__cacheline_aligned//g;
  s/____cacheline_aligned//g;
  s/__read_mostly//g;
  s/__ro_after_init//g;

  s/DECLARE_PER_CPU\s*\(\s*([^,]+)\s*,\s*([^)]+)\s*\)/$1 $2;/g;
  s/DEFINE_PER_CPU\s*\(\s*([^,]+)\s*,\s*([^)]+)\s*\)/$1 $2;/g;

  s/__struct_group\s*\([^,]*,\s*([^,]*),\s*[^,]*,\s*(.*?)\)/$2/gs;
  s/struct_group\s*\(\s*([^,]*),\s*(.*?)\)/$2/gs;

  # 4. BOUNDARY SEPARATION & SANITATION
  s/(\*\/)[ \t]*\n(?=[ \t]*(?:static|inline|extern|unsigned|void|int|long|struct|enum|union|SYSCALL_DEFINE)\b)/$1\n\n/g;
  s/\b(?:TRACE_EVENT|DEFINE_EVENT|DECLARE_TRACE)\s*\([^)]*\)\s*;/;/g;
' "$1"