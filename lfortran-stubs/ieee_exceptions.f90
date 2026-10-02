! =============================================================================
! ieee_exceptions.f90 — LFortran stub for the IEEE_EXCEPTIONS intrinsic module
!
! LFortran does not provide IEEE_EXCEPTIONS yet (lfortran/lfortran#10906).
! Its IEEE_ARITHMETIC already defines the exception entities, so this module
! re-exports them (keeping the types identical when a scope uses both modules)
! and adds IEEE_ALL. Remove this file once LFortran ships IEEE_EXCEPTIONS.
!
! Note: LFortran's halting-mode and flag procedures are currently no-ops, so
! MGLET_FPE_TRAP has no effect in lfortran builds.
! =============================================================================
MODULE ieee_exceptions
    USE, INTRINSIC :: IEEE_ARITHMETIC, ONLY: ieee_flag_type, &
        ieee_invalid, ieee_overflow, ieee_divide_by_zero, &
        ieee_underflow, ieee_inexact, &
        ieee_get_halting_mode, ieee_set_halting_mode, ieee_set_flag
    IMPLICIT NONE
    PRIVATE

    PUBLIC :: ieee_flag_type, ieee_invalid, ieee_overflow, &
        ieee_divide_by_zero, ieee_underflow, ieee_inexact, ieee_all, &
        ieee_get_halting_mode, ieee_set_halting_mode, ieee_set_flag

    ! Same order and values as ieee_invalid ... ieee_inexact in LFortran's
    ! IEEE_ARITHMETIC. Structure constructors instead of those named
    ! constants: an array of them fails to load from the .mod file in
    ! LFortran ("symbol 'ieee_flag_type' references symbol table ... which
    ! has not been deserialized yet").
    TYPE(ieee_flag_type), PARAMETER :: ieee_all(5) = [ieee_flag_type(1), &
        ieee_flag_type(2), ieee_flag_type(3), ieee_flag_type(4), &
        ieee_flag_type(5)]
END MODULE ieee_exceptions
