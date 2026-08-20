#!/usr/bin/env python3
import re
import unicodedata

def clean_whitespace(text):
    # Convert non-breaking spaces (\xa0) and exotic spaces to standard ASCII spaces
    text = unicodedata.normalize("NFKC", text)
    return text

def parse_kconfig_to_md(kconfig_file, output_md):
    with open(kconfig_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # Step 1: Normalize all non-standard space characters
    content = clean_whitespace(content)

    # Step 2: Split by 'config ' or 'choice' keywords while preserving blocks
    raw_blocks = re.split(r'\n(?=\s*(?:config|choice)\b)', content)

    md_output = [
        "# Preemption Configuration Flags {#preempt_flags_page}\n",
        "Auto-generated from `kernel/Kconfig.preempt`.\n\n",
        "| Symbol | Label / Prompt | Description |",
        "| :--- | :--- | :--- |"
    ]

    for block in raw_blocks:
        # Match symbol declaration (e.g., config PREEMPT_NONE)
        symbol_match = re.search(r'^\s*config\s+([A-Za-z0-9_]+)', block, re.MULTILINE)
        if not symbol_match:
            continue
        
        symbol = f"`CONFIG_{symbol_match.group(1)}`"
        
        # Extract prompt string (e.g., bool "No Forced Preemption (Server)")
        prompt_match = re.search(r'bool\s+"([^"]+)"', block)
        prompt = prompt_match.group(1) if prompt_match else "*Internal / Derived*"

        # Extract help text block
        help_match = re.search(r'^\s*help\b\n((?:[ \t]+.*\n?)+)', block, re.MULTILINE)
        if help_match:
            help_lines = help_match.group(1).splitlines()
            # Clean indents and replace line breaks with space for Markdown table compatibility
            cleaned_lines = [line.strip() for line in help_lines if line.strip()]
            help_text = " ".join(cleaned_lines)
            help_text = help_text.replace('|', '\\|')  # Escape table pipe characters
        else:
            help_text = "N/A"

        md_output.append(f"| {symbol} | {prompt} | {help_text} |")

    with open(output_md, 'w', encoding='utf-8') as f:
        f.write("\n".join(md_output) + "\n")

if __name__ == "__main__":
    parse_kconfig_to_md("src/kernel/Kconfig.preempt", "FLAG.md")