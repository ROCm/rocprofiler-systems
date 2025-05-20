#!/usr/bin/env bash

# MIT License
#
# Copyright (c) 2025 Advanced Micro Devices, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

expected_copyright=("Copyright (c)" ".COPYRIGHT")
files_with_missing_copyright=()
files=("$@")

for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        found=0
        for pattern in "${expected_copyright[@]}"; do
            if grep -Fq "$pattern" "$file"; then
                found=1
                break
            fi
        done
        if [[ $found -eq 0 ]]; then
            files_with_missing_copyright+=("$file")
        fi
    fi
done

if [ ${#files_with_missing_copyright[@]} -ne 0 ]; then
    if [[ "$ADD_AMD_COPYRIGHT" == "1" ]]; then  
        echo "Adding copyright notice to the missing files..."  
        for file in "${files_with_missing_copyright[@]}"; do  
            # Determine the comment style based on the file extension  
            if [[ "$file" == *.c || "$file" == *.cpp || "$file" == *.h || "$file" == *.hpp ]]; then  
                comS="//"  # For .c, .cpp, .h, .hpp files  
            else   
                comS="#"  # For .txt and other files  
            fi  
    
            # Define the full copyright notice with appropriate comment prefix  
                            copyright_notice="$comS MIT License
$comS
$comS Copyright (c) 2025 Advanced Micro Devices, Inc. All rights reserved.
$comS
$comS Permission is hereby granted, free of charge, to any person obtaining a copy
$comS of this software and associated documentation files (the \"Software\"), to deal
$comS in the Software without restriction, including without limitation the rights
$comS to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
$comS copies of the Software, and to permit persons to whom the Software is
$comS furnished to do so, subject to the following conditions:
$comS
$comS The above copyright notice and this permission notice shall be included in
$comS all copies or substantial portions of the Software.
$comS
$comS THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
$comS IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
$comS FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
$comS AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
$comS LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
$comS OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
$comS THE SOFTWARE."  
    
            # Add the notice to the beginning of the file  
            temp_file=$(mktemp)  
            {  
                echo -e "$copyright_notice\n"  
                cat "$file"  
            } > "$temp_file"  
            mv "$temp_file" "$file"  
        done  
        echo "Copyright notices added."  
        exit 1
    fi  
    echo "The following files are missing a valid copyright notice:"
    echo ""
    for file in "${files_with_missing_copyright[@]}"; do
        echo "$file"
    done
    echo ""
    echo "It may be the case that the copyright is not required by some files."
    echo "To override this check, set the environment variable ALLOW_MISSING_COPYRIGHT=1"
    echo "To add the copyright to the files, set the environment variable ADD_AMD_COPYRIGHT=1"
    if [[ "$ALLOW_MISSING_COPYRIGHT" == "1" ]]; then
        exit 0
    fi
    exit 1
fi

! $quiet && printf -- "\033[32mDone!\033[0m\n"
exit 0
