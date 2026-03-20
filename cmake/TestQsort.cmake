include(CheckCSourceRuns)

message(STATUS "Checking if your C library supports 'qsort_r'")

# -----------------------------
# Test GNU qsort_r
# -----------------------------
check_c_source_runs("
#define _GNU_SOURCE
#include <stdlib.h>

int cmp_r(const void *a, const void *b, void *arg)
{
    return 0;
}

int main()
{
    int arr[4] = {1,2,3,4};
    qsort_r(arr, 4, sizeof(int), cmp_r, NULL);
    return 0;
}
" QSORT_GNU)

# -----------------------------
# Test BSD/macOS qsort_r
# -----------------------------
check_c_source_runs("
#define _DARWIN_C_SOURCE
#include <stdlib.h>

int cmp_r(void *arg, const void *a, const void *b)
{
    return 0;
}

int main()
{
    int arr[4] = {1,2,3,4};
    qsort_r(arr, 4, sizeof(int), NULL, cmp_r);
    return 0;
}
" QSORT_BSD)

# -----------------------------
# Decide which version exists
# -----------------------------
if(QSORT_GNU)
    message(STATUS "Using GNU qsort_r")
    add_compile_definitions(QSORT_R_GNU)

elseif(QSORT_BSD)
    message(STATUS "Using BSD/macOS qsort_r")
    add_compile_definitions(QSORT_R_BSD)

else()
    message(FATAL_ERROR "Your C library does not support 'qsort_r'")
endif()
