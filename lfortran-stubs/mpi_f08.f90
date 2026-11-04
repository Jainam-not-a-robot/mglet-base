! =============================================================================
! mpi_f08.f90 — LFortran-compilable stub for the MPI_f08 module
!
! Covers everything mglet-base uses from MPI_f08. Open MPI's own mpi_f08.mod
! is in gfortran format, which LFortran cannot read, so this module provides
! the same names for LFortran.
!
! Each MPI procedure is a wrapper that calls the C shim in mpi_f08_shim.c,
! which calls Open MPI's C API. A choice buffer is passed to the shim as a
! BIND(C) assumed-rank argument, so the shim receives the address of the
! actual argument (an array, an array element, a scalar or a component).
! Handles are Open MPI Fortran handles: the constants below are the values
! of Open MPI 4.1 (mpif-handles.h, mpif-constants.h), and MPI_Init checks
! them against the library it runs with.
! =============================================================================
MODULE mpi_f08
    USE, INTRINSIC :: ISO_C_BINDING
    IMPLICIT NONE

    ! ── Derived types ──────────────────────────────────────────────────────────
    TYPE :: MPI_Datatype
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Datatype

    TYPE :: MPI_Comm
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Comm

    TYPE :: MPI_Op
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Op

    ! MPI_STATUS_SIZE default integers, as in Open MPI's mpi_f08
    TYPE, BIND(C) :: MPI_Status
        INTEGER(c_int) :: MPI_SOURCE
        INTEGER(c_int) :: MPI_TAG
        INTEGER(c_int) :: MPI_ERROR
        INTEGER(c_int) :: OMPI_internal(3)
    END TYPE MPI_Status

    TYPE :: MPI_Request
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Request

    TYPE :: MPI_Info
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Info

    TYPE :: MPI_Errhandler
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Errhandler

    TYPE :: MPI_Win
        INTEGER :: MPI_VAL = 0
    END TYPE MPI_Win

    ! MPI_Aint — address-sized integer kind
    INTEGER, PARAMETER :: MPI_ADDRESS_KIND = 8

    ! MPI_Aint as a predefined datatype (used in MPI_Allreduce etc.)
    TYPE(MPI_Datatype), PARAMETER :: MPI_Aint = MPI_Datatype(66)

    ! ── Communicators ──────────────────────────────────────────────────────────
    TYPE(MPI_Comm), PARAMETER :: MPI_COMM_WORLD = MPI_Comm(0)
    TYPE(MPI_Comm), PARAMETER :: MPI_COMM_NULL  = MPI_Comm(2)

    ! ── Windows ────────────────────────────────────────────────────────────────
    TYPE(MPI_Win), PARAMETER :: MPI_WIN_NULL = MPI_Win(0)

    ! ── Datatypes ──────────────────────────────────────────────────────────────
    TYPE(MPI_Datatype), PARAMETER :: MPI_BYTE             = MPI_Datatype(1)
    TYPE(MPI_Datatype), PARAMETER :: MPI_REAL             = MPI_Datatype(13)
    TYPE(MPI_Datatype), PARAMETER :: MPI_DOUBLE_PRECISION  = MPI_Datatype(17)
    TYPE(MPI_Datatype), PARAMETER :: MPI_INTEGER           = MPI_Datatype(7)
    TYPE(MPI_Datatype), PARAMETER :: MPI_INTEGER8          = MPI_Datatype(11)
    TYPE(MPI_Datatype), PARAMETER :: MPI_LOGICAL           = MPI_Datatype(6)
    TYPE(MPI_Datatype), PARAMETER :: MPI_CHARACTER         = MPI_Datatype(5)
    TYPE(MPI_Datatype), PARAMETER :: MPI_REAL8             = MPI_Datatype(15)

    ! ── Operators ──────────────────────────────────────────────────────────────
    TYPE(MPI_Op), PARAMETER :: MPI_SUM = MPI_Op(3)
    TYPE(MPI_Op), PARAMETER :: MPI_MAX = MPI_Op(1)
    TYPE(MPI_Op), PARAMETER :: MPI_MIN = MPI_Op(2)

    ! ── Requests / info ────────────────────────────────────────────────────────
    TYPE(MPI_Request), PARAMETER :: MPI_REQUEST_NULL = MPI_Request(0)
    TYPE(MPI_Info),    PARAMETER :: MPI_INFO_NULL    = MPI_Info(0)

    ! ── Integer constants ──────────────────────────────────────────────────────
    INTEGER, PARAMETER :: MPI_SUCCESS                  = 0
    INTEGER, PARAMETER :: MPI_UNDEFINED                = -32766
    INTEGER, PARAMETER :: MPI_PROC_NULL                = -2
    INTEGER, PARAMETER :: MPI_COMM_TYPE_SHARED         = 0
    INTEGER, PARAMETER :: MPI_STATUS_SIZE              = 6
    INTEGER, PARAMETER :: MPI_MAX_ERROR_STRING         = 255
    INTEGER, PARAMETER :: MPI_MAX_LIBRARY_VERSION_STRING = 255

    ! ── Sentinels ──────────────────────────────────────────────────────────────
    ! The shim recognizes these by address; MPI_Init registers the addresses.
    TYPE(MPI_Status), TARGET :: MPI_STATUS_IGNORE
    TYPE(MPI_Status), TARGET :: MPI_STATUSES_IGNORE(1)
    INTEGER, TARGET :: MPI_IN_PLACE

    ! ── Abstract interface for user-defined MPI reduction operations ──────────
    ! Matches the MPI-3.1 mpi_f08 definition used by MPI_Op_create.
    ABSTRACT INTERFACE
        SUBROUTINE MPI_User_function(invec, inoutvec, len, datatype)
            IMPORT :: MPI_Datatype, c_ptr
            TYPE(c_ptr), VALUE :: invec, inoutvec
            INTEGER :: len
            TYPE(MPI_Datatype) :: datatype
        END SUBROUTINE

        SUBROUTINE MPI_Comm_errhandler_function(comm, error_code)
            IMPORT :: MPI_Comm
            TYPE(MPI_Comm) :: comm
            INTEGER        :: error_code
        END SUBROUTINE
    END INTERFACE

    ! ── Comparison operators for derived types ────────────────────────────────
    INTERFACE OPERATOR(==)
        MODULE PROCEDURE mpi_datatype_eq
    END INTERFACE
    INTERFACE OPERATOR(/=)
        MODULE PROCEDURE mpi_datatype_ne
    END INTERFACE

    ! ── C shim (mpi_f08_shim.c) ───────────────────────────────────────────────
    ! Each function returns the MPI error code.
    INTERFACE
        SUBROUTINE lfmpi_set_sentinels(in_place, status_ignore, statuses_ignore) &
                BIND(C, name="lfmpi_set_sentinels")
            IMPORT :: c_ptr
            TYPE(c_ptr), VALUE :: in_place, status_ignore, statuses_ignore
        END SUBROUTINE

        INTEGER(c_int) FUNCTION lfmpi_check_constants(values) &
                BIND(C, name="lfmpi_check_constants")
            IMPORT :: c_int
            INTEGER(c_int), INTENT(IN) :: values(*)
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_init() BIND(C, name="lfmpi_init")
            IMPORT :: c_int
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_finalize() BIND(C, name="lfmpi_finalize")
            IMPORT :: c_int
        END FUNCTION

        REAL(c_double) FUNCTION lfmpi_wtime() BIND(C, name="lfmpi_wtime")
            IMPORT :: c_double
        END FUNCTION

        REAL(c_double) FUNCTION lfmpi_wtick() BIND(C, name="lfmpi_wtick")
            IMPORT :: c_double
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_abort(comm, errorcode) &
                BIND(C, name="lfmpi_abort")
            IMPORT :: c_int
            INTEGER(c_int), VALUE :: comm, errorcode
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_error_class(errorcode, errorclass) &
                BIND(C, name="lfmpi_error_class")
            IMPORT :: c_int
            INTEGER(c_int), VALUE :: errorcode
            INTEGER(c_int), INTENT(OUT) :: errorclass
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_error_string(errorcode, string, resultlen) &
                BIND(C, name="lfmpi_error_string")
            IMPORT :: c_int, c_char
            INTEGER(c_int), VALUE :: errorcode
            CHARACTER(KIND=c_char), INTENT(OUT) :: string(*)
            INTEGER(c_int), INTENT(OUT) :: resultlen
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_get_library_version(version, resultlen) &
                BIND(C, name="lfmpi_get_library_version")
            IMPORT :: c_int, c_char
            CHARACTER(KIND=c_char), INTENT(OUT) :: version(*)
            INTEGER(c_int), INTENT(OUT) :: resultlen
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_comm_rank(comm, rank) &
                BIND(C, name="lfmpi_comm_rank")
            IMPORT :: c_int
            INTEGER(c_int), VALUE :: comm
            INTEGER(c_int), INTENT(OUT) :: rank
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_comm_size(comm, size) &
                BIND(C, name="lfmpi_comm_size")
            IMPORT :: c_int
            INTEGER(c_int), VALUE :: comm
            INTEGER(c_int), INTENT(OUT) :: size
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_comm_dup(comm, newcomm) &
                BIND(C, name="lfmpi_comm_dup")
            IMPORT :: c_int
            INTEGER(c_int), VALUE :: comm
            INTEGER(c_int), INTENT(OUT) :: newcomm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_comm_free(comm) &
                BIND(C, name="lfmpi_comm_free")
            IMPORT :: c_int
            INTEGER(c_int), INTENT(INOUT) :: comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_comm_split(comm, color, key, newcomm) &
                BIND(C, name="lfmpi_comm_split")
            IMPORT :: c_int
            INTEGER(c_int), VALUE :: comm, color, key
            INTEGER(c_int), INTENT(OUT) :: newcomm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_comm_split_type(comm, split_type, key, &
                info, newcomm) BIND(C, name="lfmpi_comm_split_type")
            IMPORT :: c_int
            INTEGER(c_int), VALUE :: comm, split_type, key, info
            INTEGER(c_int), INTENT(OUT) :: newcomm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_comm_create_errhandler(function, errhandler) &
                BIND(C, name="lfmpi_comm_create_errhandler")
            IMPORT :: c_int, c_funptr
            TYPE(c_funptr), VALUE :: function
            INTEGER(c_int), INTENT(OUT) :: errhandler
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_comm_set_errhandler(comm, errhandler) &
                BIND(C, name="lfmpi_comm_set_errhandler")
            IMPORT :: c_int
            INTEGER(c_int), VALUE :: comm, errhandler
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_errhandler_free(errhandler) &
                BIND(C, name="lfmpi_errhandler_free")
            IMPORT :: c_int
            INTEGER(c_int), INTENT(INOUT) :: errhandler
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_send(buf, count, datatype, dest, tag, comm) &
                BIND(C, name="lfmpi_send")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..), INTENT(IN) :: buf
            INTEGER(c_int), VALUE :: count, datatype, dest, tag, comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_recv(buf, count, datatype, source, tag, &
                comm, status) BIND(C, name="lfmpi_recv")
            IMPORT :: c_int, MPI_Status
            TYPE(*), DIMENSION(..) :: buf
            INTEGER(c_int), VALUE :: count, datatype, source, tag, comm
            TYPE(MPI_Status) :: status
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_isend(buf, count, datatype, dest, tag, &
                comm, request) BIND(C, name="lfmpi_isend")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..), INTENT(IN) :: buf
            INTEGER(c_int), VALUE :: count, datatype, dest, tag, comm
            INTEGER(c_int), INTENT(OUT) :: request
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_irecv(buf, count, datatype, source, tag, &
                comm, request) BIND(C, name="lfmpi_irecv")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..) :: buf
            INTEGER(c_int), VALUE :: count, datatype, source, tag, comm
            INTEGER(c_int), INTENT(OUT) :: request
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_wait(request, status) &
                BIND(C, name="lfmpi_wait")
            IMPORT :: c_int, MPI_Status
            INTEGER(c_int), INTENT(INOUT) :: request
            TYPE(MPI_Status) :: status
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_waitall(count, requests, statuses) &
                BIND(C, name="lfmpi_waitall")
            IMPORT :: c_int, MPI_Status
            INTEGER(c_int), VALUE :: count
            INTEGER(c_int), INTENT(INOUT) :: requests(*)
            TYPE(MPI_Status) :: statuses(*)
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_waitany(count, requests, index, status) &
                BIND(C, name="lfmpi_waitany")
            IMPORT :: c_int, MPI_Status
            INTEGER(c_int), VALUE :: count
            INTEGER(c_int), INTENT(INOUT) :: requests(*)
            INTEGER(c_int), INTENT(OUT) :: index
            TYPE(MPI_Status) :: status
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_get_count(status, datatype, count) &
                BIND(C, name="lfmpi_get_count")
            IMPORT :: c_int, MPI_Status
            TYPE(MPI_Status), INTENT(IN) :: status
            INTEGER(c_int), VALUE :: datatype
            INTEGER(c_int), INTENT(OUT) :: count
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_barrier(comm) BIND(C, name="lfmpi_barrier")
            IMPORT :: c_int
            INTEGER(c_int), VALUE :: comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_bcast(buffer, count, datatype, root, comm) &
                BIND(C, name="lfmpi_bcast")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..) :: buffer
            INTEGER(c_int), VALUE :: count, datatype, root, comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_reduce(sendbuf, recvbuf, count, datatype, &
                op, root, comm) BIND(C, name="lfmpi_reduce")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..), INTENT(IN) :: sendbuf
            TYPE(*), DIMENSION(..) :: recvbuf
            INTEGER(c_int), VALUE :: count, datatype, op, root, comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_allreduce(sendbuf, recvbuf, count, &
                datatype, op, comm) BIND(C, name="lfmpi_allreduce")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..), INTENT(IN) :: sendbuf
            TYPE(*), DIMENSION(..) :: recvbuf
            INTEGER(c_int), VALUE :: count, datatype, op, comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_gather(sendbuf, sendcount, sendtype, &
                recvbuf, recvcount, recvtype, root, comm) &
                BIND(C, name="lfmpi_gather")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..), INTENT(IN) :: sendbuf
            TYPE(*), DIMENSION(..) :: recvbuf
            INTEGER(c_int), VALUE :: sendcount, sendtype, recvcount, recvtype, &
                root, comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_gatherv(sendbuf, sendcount, sendtype, &
                recvbuf, recvcounts, displs, recvtype, root, comm) &
                BIND(C, name="lfmpi_gatherv")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..), INTENT(IN) :: sendbuf
            TYPE(*), DIMENSION(..) :: recvbuf
            INTEGER(c_int), INTENT(IN) :: recvcounts(*), displs(*)
            INTEGER(c_int), VALUE :: sendcount, sendtype, recvtype, root, comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_scatterv(sendbuf, sendcounts, displs, &
                sendtype, recvbuf, recvcount, recvtype, root, comm) &
                BIND(C, name="lfmpi_scatterv")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..), INTENT(IN) :: sendbuf
            TYPE(*), DIMENSION(..) :: recvbuf
            INTEGER(c_int), INTENT(IN) :: sendcounts(*), displs(*)
            INTEGER(c_int), VALUE :: sendtype, recvcount, recvtype, root, comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_allgather(sendbuf, sendcount, sendtype, &
                recvbuf, recvcount, recvtype, comm) &
                BIND(C, name="lfmpi_allgather")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..), INTENT(IN) :: sendbuf
            TYPE(*), DIMENSION(..) :: recvbuf
            INTEGER(c_int), VALUE :: sendcount, sendtype, recvcount, recvtype, comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_allgatherv(sendbuf, sendcount, sendtype, &
                recvbuf, recvcounts, displs, recvtype, comm) &
                BIND(C, name="lfmpi_allgatherv")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..), INTENT(IN) :: sendbuf
            TYPE(*), DIMENSION(..) :: recvbuf
            INTEGER(c_int), INTENT(IN) :: recvcounts(*), displs(*)
            INTEGER(c_int), VALUE :: sendcount, sendtype, recvtype, comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_alltoall(sendbuf, sendcount, sendtype, &
                recvbuf, recvcount, recvtype, comm) &
                BIND(C, name="lfmpi_alltoall")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..), INTENT(IN) :: sendbuf
            TYPE(*), DIMENSION(..) :: recvbuf
            INTEGER(c_int), VALUE :: sendcount, sendtype, recvcount, recvtype, comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_alltoallv(sendbuf, sendcounts, sdispls, &
                sendtype, recvbuf, recvcounts, rdispls, recvtype, comm) &
                BIND(C, name="lfmpi_alltoallv")
            IMPORT :: c_int
            TYPE(*), DIMENSION(..), INTENT(IN) :: sendbuf
            TYPE(*), DIMENSION(..) :: recvbuf
            INTEGER(c_int), INTENT(IN) :: sendcounts(*), sdispls(*), &
                recvcounts(*), rdispls(*)
            INTEGER(c_int), VALUE :: sendtype, recvtype, comm
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_get_address(location, address) &
                BIND(C, name="lfmpi_get_address")
            IMPORT :: c_int, c_intptr_t
            TYPE(*), DIMENSION(..), INTENT(IN) :: location
            INTEGER(c_intptr_t), INTENT(OUT) :: address
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_type_contiguous(count, oldtype, newtype) &
                BIND(C, name="lfmpi_type_contiguous")
            IMPORT :: c_int
            INTEGER(c_int), VALUE :: count, oldtype
            INTEGER(c_int), INTENT(OUT) :: newtype
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_type_indexed(count, blocklengths, &
                displacements, oldtype, newtype) &
                BIND(C, name="lfmpi_type_indexed")
            IMPORT :: c_int
            INTEGER(c_int), VALUE :: count, oldtype
            INTEGER(c_int), INTENT(IN) :: blocklengths(*), displacements(*)
            INTEGER(c_int), INTENT(OUT) :: newtype
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_type_create_struct(count, blocklengths, &
                displacements, types, newtype) &
                BIND(C, name="lfmpi_type_create_struct")
            IMPORT :: c_int, c_intptr_t
            INTEGER(c_int), VALUE :: count
            INTEGER(c_int), INTENT(IN) :: blocklengths(*), types(*)
            INTEGER(c_intptr_t), INTENT(IN) :: displacements(*)
            INTEGER(c_int), INTENT(OUT) :: newtype
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_type_commit(datatype) &
                BIND(C, name="lfmpi_type_commit")
            IMPORT :: c_int
            INTEGER(c_int), INTENT(INOUT) :: datatype
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_type_free(datatype) &
                BIND(C, name="lfmpi_type_free")
            IMPORT :: c_int
            INTEGER(c_int), INTENT(INOUT) :: datatype
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_type_get_extent(datatype, lb, extent) &
                BIND(C, name="lfmpi_type_get_extent")
            IMPORT :: c_int, c_intptr_t
            INTEGER(c_int), VALUE :: datatype
            INTEGER(c_intptr_t), INTENT(OUT) :: lb, extent
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_type_create_resized(oldtype, lb, extent, &
                newtype) BIND(C, name="lfmpi_type_create_resized")
            IMPORT :: c_int, c_intptr_t
            INTEGER(c_int), VALUE :: oldtype
            INTEGER(c_intptr_t), VALUE :: lb, extent
            INTEGER(c_int), INTENT(OUT) :: newtype
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_op_create(function, commute, op) &
                BIND(C, name="lfmpi_op_create")
            IMPORT :: c_int, c_funptr
            TYPE(c_funptr), VALUE :: function
            INTEGER(c_int), VALUE :: commute
            INTEGER(c_int), INTENT(OUT) :: op
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_op_free(op) BIND(C, name="lfmpi_op_free")
            IMPORT :: c_int
            INTEGER(c_int), INTENT(INOUT) :: op
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_win_allocate_shared(size, disp_unit, info, &
                comm, baseptr, win) BIND(C, name="lfmpi_win_allocate_shared")
            IMPORT :: c_int, c_intptr_t, c_ptr
            INTEGER(c_intptr_t), VALUE :: size
            INTEGER(c_int), VALUE :: disp_unit, info, comm
            TYPE(c_ptr), INTENT(OUT) :: baseptr
            INTEGER(c_int), INTENT(OUT) :: win
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_win_shared_query(win, rank, size, &
                disp_unit, baseptr) BIND(C, name="lfmpi_win_shared_query")
            IMPORT :: c_int, c_intptr_t, c_ptr
            INTEGER(c_int), VALUE :: win, rank
            INTEGER(c_intptr_t), INTENT(OUT) :: size
            INTEGER(c_int), INTENT(OUT) :: disp_unit
            TYPE(c_ptr), INTENT(OUT) :: baseptr
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_win_fence(assert, win) &
                BIND(C, name="lfmpi_win_fence")
            IMPORT :: c_int
            INTEGER(c_int), VALUE :: assert, win
        END FUNCTION

        INTEGER(c_int) FUNCTION lfmpi_win_free(win) BIND(C, name="lfmpi_win_free")
            IMPORT :: c_int
            INTEGER(c_int), INTENT(INOUT) :: win
        END FUNCTION
    END INTERFACE

    PRIVATE :: lfmpi_set_sentinels, lfmpi_check_constants, lfmpi_init, &
        lfmpi_finalize, lfmpi_wtime, lfmpi_wtick, lfmpi_abort, &
        lfmpi_error_class, lfmpi_error_string, lfmpi_get_library_version, &
        lfmpi_comm_rank, lfmpi_comm_size, lfmpi_comm_dup, lfmpi_comm_free, &
        lfmpi_comm_split, lfmpi_comm_split_type, lfmpi_comm_create_errhandler, &
        lfmpi_comm_set_errhandler, lfmpi_errhandler_free, lfmpi_send, &
        lfmpi_recv, lfmpi_isend, lfmpi_irecv, lfmpi_wait, lfmpi_waitall, &
        lfmpi_waitany, lfmpi_get_count, lfmpi_barrier, lfmpi_bcast, &
        lfmpi_reduce, lfmpi_allreduce, lfmpi_gather, lfmpi_gatherv, &
        lfmpi_scatterv, lfmpi_allgather, lfmpi_allgatherv, lfmpi_alltoall, &
        lfmpi_alltoallv, lfmpi_get_address, lfmpi_type_contiguous, &
        lfmpi_type_indexed, lfmpi_type_create_struct, lfmpi_type_commit, &
        lfmpi_type_free, lfmpi_type_get_extent, lfmpi_type_create_resized, &
        lfmpi_op_create, lfmpi_op_free, lfmpi_win_allocate_shared, &
        lfmpi_win_shared_query, lfmpi_win_fence, lfmpi_win_free, set_ierror, &
        copy_c_string

CONTAINS
    PURE LOGICAL FUNCTION mpi_datatype_eq(a, b)
        TYPE(MPI_Datatype), INTENT(IN) :: a, b
        mpi_datatype_eq = (a%MPI_VAL == b%MPI_VAL)
    END FUNCTION
    PURE LOGICAL FUNCTION mpi_datatype_ne(a, b)
        TYPE(MPI_Datatype), INTENT(IN) :: a, b
        mpi_datatype_ne = (a%MPI_VAL /= b%MPI_VAL)
    END FUNCTION

    SUBROUTINE set_ierror(ierror, ie)
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        INTEGER(c_int), INTENT(IN) :: ie
        IF (PRESENT(ierror)) ierror = ie
    END SUBROUTINE

    ! Copy the first `n` characters of `cbuf` into `string`, blank-padded
    SUBROUTINE copy_c_string(cbuf, n, string)
        CHARACTER(KIND=c_char), INTENT(IN) :: cbuf(*)
        INTEGER, INTENT(IN) :: n
        CHARACTER(LEN=*), INTENT(OUT) :: string
        INTEGER :: i
        string = ' '
        DO i = 1, MIN(n, LEN(string))
            string(i:i) = cbuf(i)
        END DO
    END SUBROUTINE

    ! ── Environment ───────────────────────────────────────────────────────────

    SUBROUTINE MPI_Init(ierror)
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        INTEGER(c_int) :: ie
        CALL lfmpi_set_sentinels(c_loc(MPI_IN_PLACE), c_loc(MPI_STATUS_IGNORE), &
            c_loc(MPI_STATUSES_IGNORE(1)))
        ie = lfmpi_init()
        ! Same order as lfmpi_check_constants in mpi_f08_shim.c
        IF (ie == MPI_SUCCESS) ie = lfmpi_check_constants([ &
            MPI_COMM_WORLD%MPI_VAL, MPI_COMM_NULL%MPI_VAL, MPI_WIN_NULL%MPI_VAL, &
            MPI_BYTE%MPI_VAL, MPI_REAL%MPI_VAL, MPI_DOUBLE_PRECISION%MPI_VAL, &
            MPI_INTEGER%MPI_VAL, MPI_INTEGER8%MPI_VAL, MPI_LOGICAL%MPI_VAL, &
            MPI_CHARACTER%MPI_VAL, MPI_REAL8%MPI_VAL, MPI_Aint%MPI_VAL, &
            MPI_SUM%MPI_VAL, MPI_MAX%MPI_VAL, MPI_MIN%MPI_VAL, &
            MPI_REQUEST_NULL%MPI_VAL, MPI_INFO_NULL%MPI_VAL, MPI_UNDEFINED, &
            MPI_PROC_NULL, MPI_COMM_TYPE_SHARED, MPI_STATUS_SIZE, &
            MPI_MAX_ERROR_STRING, MPI_MAX_LIBRARY_VERSION_STRING, &
            MPI_ADDRESS_KIND])
        CALL set_ierror(ierror, ie)
    END SUBROUTINE

    SUBROUTINE MPI_Finalize(ierror)
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_finalize())
    END SUBROUTINE

    SUBROUTINE MPI_Abort(comm, errorcode, ierror)
        TYPE(MPI_Comm), INTENT(IN)  :: comm
        INTEGER,        INTENT(IN)  :: errorcode
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_abort(comm%MPI_VAL, errorcode))
    END SUBROUTINE

    SUBROUTINE MPI_Error_class(errorcode, errorclass, ierror)
        INTEGER, INTENT(IN)  :: errorcode
        INTEGER, INTENT(OUT) :: errorclass
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_error_class(errorcode, errorclass))
    END SUBROUTINE

    SUBROUTINE MPI_Error_string(errorcode, string, resultlen, ierror)
        INTEGER,          INTENT(IN)  :: errorcode
        CHARACTER(LEN=*), INTENT(OUT) :: string
        INTEGER,          INTENT(OUT) :: resultlen
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CHARACTER(KIND=c_char) :: cbuf(MPI_MAX_ERROR_STRING + 1)
        INTEGER(c_int) :: ie
        ie = lfmpi_error_string(errorcode, cbuf, resultlen)
        CALL copy_c_string(cbuf, resultlen, string)
        CALL set_ierror(ierror, ie)
    END SUBROUTINE

    SUBROUTINE MPI_Get_library_version(version, resultlen, ierror)
        CHARACTER(LEN=*), INTENT(OUT) :: version
        INTEGER,          INTENT(OUT) :: resultlen
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CHARACTER(KIND=c_char) :: cbuf(MPI_MAX_LIBRARY_VERSION_STRING + 1)
        INTEGER(c_int) :: ie
        ie = lfmpi_get_library_version(cbuf, resultlen)
        CALL copy_c_string(cbuf, resultlen, version)
        CALL set_ierror(ierror, ie)
    END SUBROUTINE

    DOUBLE PRECISION FUNCTION MPI_Wtime()
        MPI_Wtime = lfmpi_wtime()
    END FUNCTION

    DOUBLE PRECISION FUNCTION MPI_Wtick()
        MPI_Wtick = lfmpi_wtick()
    END FUNCTION

    ! ── Communicators and error handlers ─────────────────────────────────────

    SUBROUTINE MPI_Comm_rank(comm, rank, ierror)
        TYPE(MPI_Comm), INTENT(IN)  :: comm
        INTEGER,        INTENT(OUT) :: rank
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_comm_rank(comm%MPI_VAL, rank))
    END SUBROUTINE

    SUBROUTINE MPI_Comm_size(comm, size, ierror)
        TYPE(MPI_Comm), INTENT(IN)  :: comm
        INTEGER,        INTENT(OUT) :: size
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_comm_size(comm%MPI_VAL, size))
    END SUBROUTINE

    SUBROUTINE MPI_Comm_dup(comm, newcomm, ierror)
        TYPE(MPI_Comm), INTENT(IN)  :: comm
        TYPE(MPI_Comm), INTENT(OUT) :: newcomm
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_comm_dup(comm%MPI_VAL, newcomm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Comm_free(comm, ierror)
        TYPE(MPI_Comm), INTENT(INOUT) :: comm
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_comm_free(comm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Comm_split(comm, color, key, newcomm, ierror)
        TYPE(MPI_Comm), INTENT(IN)  :: comm
        INTEGER,        INTENT(IN)  :: color
        INTEGER,        INTENT(IN)  :: key
        TYPE(MPI_Comm), INTENT(OUT) :: newcomm
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_comm_split(comm%MPI_VAL, color, key, &
            newcomm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Comm_split_type(comm, split_type, key, info, newcomm, ierror)
        TYPE(MPI_Comm), INTENT(IN)  :: comm
        INTEGER,        INTENT(IN)  :: split_type
        INTEGER,        INTENT(IN)  :: key
        TYPE(MPI_Info), INTENT(IN)  :: info
        TYPE(MPI_Comm), INTENT(OUT) :: newcomm
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_comm_split_type(comm%MPI_VAL, split_type, &
            key, info%MPI_VAL, newcomm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Comm_create_errhandler(comm_errhandler_fn, errhandler, ierror)
        PROCEDURE(MPI_Comm_errhandler_function) :: comm_errhandler_fn
        TYPE(MPI_Errhandler), INTENT(OUT) :: errhandler
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_comm_create_errhandler( &
            c_funloc(comm_errhandler_fn), errhandler%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Comm_set_errhandler(comm, errhandler, ierror)
        TYPE(MPI_Comm),       INTENT(IN)  :: comm
        TYPE(MPI_Errhandler), INTENT(IN)  :: errhandler
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_comm_set_errhandler(comm%MPI_VAL, &
            errhandler%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Errhandler_free(errhandler, ierror)
        TYPE(MPI_Errhandler), INTENT(INOUT) :: errhandler
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_errhandler_free(errhandler%MPI_VAL))
    END SUBROUTINE

    ! ── Point to point ────────────────────────────────────────────────────────

    SUBROUTINE MPI_Send(buf, count, datatype, dest, tag, comm, ierror)
        TYPE(*), DIMENSION(..), INTENT(IN)  :: buf
        INTEGER,            INTENT(IN)  :: count
        TYPE(MPI_Datatype), INTENT(IN)  :: datatype
        INTEGER,            INTENT(IN)  :: dest
        INTEGER,            INTENT(IN)  :: tag
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_send(buf, count, datatype%MPI_VAL, dest, &
            tag, comm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Recv(buf, count, datatype, source, tag, comm, status, ierror)
        TYPE(*), DIMENSION(..)          :: buf
        INTEGER,            INTENT(IN)  :: count
        TYPE(MPI_Datatype), INTENT(IN)  :: datatype
        INTEGER,            INTENT(IN)  :: source
        INTEGER,            INTENT(IN)  :: tag
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        TYPE(MPI_Status)                :: status
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_recv(buf, count, datatype%MPI_VAL, source, &
            tag, comm%MPI_VAL, status))
    END SUBROUTINE

    SUBROUTINE MPI_Isend(buf, count, datatype, dest, tag, comm, request, ierror)
        TYPE(*), DIMENSION(..), INTENT(IN)  :: buf
        INTEGER,            INTENT(IN)  :: count
        TYPE(MPI_Datatype), INTENT(IN)  :: datatype
        INTEGER,            INTENT(IN)  :: dest
        INTEGER,            INTENT(IN)  :: tag
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        TYPE(MPI_Request),  INTENT(OUT) :: request
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_isend(buf, count, datatype%MPI_VAL, dest, &
            tag, comm%MPI_VAL, request%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Irecv(buf, count, datatype, source, tag, comm, request, ierror)
        TYPE(*), DIMENSION(..)          :: buf
        INTEGER,            INTENT(IN)  :: count
        TYPE(MPI_Datatype), INTENT(IN)  :: datatype
        INTEGER,            INTENT(IN)  :: source
        INTEGER,            INTENT(IN)  :: tag
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        TYPE(MPI_Request),  INTENT(OUT) :: request
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_irecv(buf, count, datatype%MPI_VAL, source, &
            tag, comm%MPI_VAL, request%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Wait(request, status, ierror)
        TYPE(MPI_Request), INTENT(INOUT) :: request
        TYPE(MPI_Status)                 :: status
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_wait(request%MPI_VAL, status))
    END SUBROUTINE

    SUBROUTINE MPI_Waitall(count, array_of_requests, array_of_statuses, ierror)
        INTEGER,           INTENT(IN)    :: count
        TYPE(MPI_Request), INTENT(INOUT) :: array_of_requests(count)
        TYPE(MPI_Status)                 :: array_of_statuses(*)
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        INTEGER(c_int) :: handles(count), ie
        handles = array_of_requests%MPI_VAL
        ie = lfmpi_waitall(count, handles, array_of_statuses)
        array_of_requests%MPI_VAL = handles
        CALL set_ierror(ierror, ie)
    END SUBROUTINE

    SUBROUTINE MPI_Waitany(count, array_of_requests, index, status, ierror)
        INTEGER,           INTENT(IN)    :: count
        TYPE(MPI_Request), INTENT(INOUT) :: array_of_requests(count)
        INTEGER,           INTENT(OUT)   :: index
        TYPE(MPI_Status)                 :: status
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        INTEGER(c_int) :: handles(count), ie
        handles = array_of_requests%MPI_VAL
        ie = lfmpi_waitany(count, handles, index, status)
        array_of_requests%MPI_VAL = handles
        CALL set_ierror(ierror, ie)
    END SUBROUTINE

    SUBROUTINE MPI_Get_count(status, datatype, count, ierror)
        TYPE(MPI_Status),   INTENT(IN)  :: status
        TYPE(MPI_Datatype), INTENT(IN)  :: datatype
        INTEGER,            INTENT(OUT) :: count
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_get_count(status, datatype%MPI_VAL, count))
    END SUBROUTINE

    ! ── Collectives ───────────────────────────────────────────────────────────

    SUBROUTINE MPI_Barrier(comm, ierror)
        TYPE(MPI_Comm), INTENT(IN)  :: comm
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_barrier(comm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Bcast(buffer, count, datatype, root, comm, ierror)
        TYPE(*), DIMENSION(..)            :: buffer
        INTEGER,            INTENT(IN)    :: count
        TYPE(MPI_Datatype), INTENT(IN)    :: datatype
        INTEGER,            INTENT(IN)    :: root
        TYPE(MPI_Comm),     INTENT(IN)    :: comm
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_bcast(buffer, count, datatype%MPI_VAL, &
            root, comm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Reduce(sendbuf, recvbuf, count, datatype, op, root, comm, ierror)
        TYPE(*), DIMENSION(..), INTENT(IN)  :: sendbuf
        TYPE(*), DIMENSION(..)          :: recvbuf
        INTEGER,            INTENT(IN)  :: count
        TYPE(MPI_Datatype), INTENT(IN)  :: datatype
        TYPE(MPI_Op),       INTENT(IN)  :: op
        INTEGER,            INTENT(IN)  :: root
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_reduce(sendbuf, recvbuf, count, &
            datatype%MPI_VAL, op%MPI_VAL, root, comm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Allreduce(sendbuf, recvbuf, count, datatype, op, comm, ierror)
        TYPE(*), DIMENSION(..), INTENT(IN)  :: sendbuf
        TYPE(*), DIMENSION(..)          :: recvbuf
        INTEGER,            INTENT(IN)  :: count
        TYPE(MPI_Datatype), INTENT(IN)  :: datatype
        TYPE(MPI_Op),       INTENT(IN)  :: op
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_allreduce(sendbuf, recvbuf, count, &
            datatype%MPI_VAL, op%MPI_VAL, comm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Gather(sendbuf, sendcount, sendtype, recvbuf, &
                          recvcount, recvtype, root, comm, ierror)
        TYPE(*), DIMENSION(..), INTENT(IN)  :: sendbuf
        INTEGER,            INTENT(IN)  :: sendcount
        TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
        TYPE(*), DIMENSION(..)          :: recvbuf
        INTEGER,            INTENT(IN)  :: recvcount
        TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
        INTEGER,            INTENT(IN)  :: root
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_gather(sendbuf, sendcount, &
            sendtype%MPI_VAL, recvbuf, recvcount, recvtype%MPI_VAL, root, &
            comm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Gatherv(sendbuf, sendcount, sendtype, recvbuf, &
                           recvcounts, displs, recvtype, root, comm, ierror)
        TYPE(*), DIMENSION(..), INTENT(IN)  :: sendbuf
        INTEGER,            INTENT(IN)  :: sendcount
        TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
        TYPE(*), DIMENSION(..)          :: recvbuf
        INTEGER,            INTENT(IN)  :: recvcounts(*)
        INTEGER,            INTENT(IN)  :: displs(*)
        TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
        INTEGER,            INTENT(IN)  :: root
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_gatherv(sendbuf, sendcount, &
            sendtype%MPI_VAL, recvbuf, recvcounts, displs, recvtype%MPI_VAL, &
            root, comm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Scatterv(sendbuf, sendcounts, displs, sendtype, recvbuf, &
                            recvcount, recvtype, root, comm, ierror)
        TYPE(*), DIMENSION(..), INTENT(IN)  :: sendbuf
        INTEGER,            INTENT(IN)  :: sendcounts(*)
        INTEGER,            INTENT(IN)  :: displs(*)
        TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
        TYPE(*), DIMENSION(..)          :: recvbuf
        INTEGER,            INTENT(IN)  :: recvcount
        TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
        INTEGER,            INTENT(IN)  :: root
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_scatterv(sendbuf, sendcounts, displs, &
            sendtype%MPI_VAL, recvbuf, recvcount, recvtype%MPI_VAL, root, &
            comm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Allgather(sendbuf, sendcount, sendtype, recvbuf, &
                             recvcount, recvtype, comm, ierror)
        TYPE(*), DIMENSION(..), INTENT(IN)  :: sendbuf
        INTEGER,            INTENT(IN)  :: sendcount
        TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
        TYPE(*), DIMENSION(..)          :: recvbuf
        INTEGER,            INTENT(IN)  :: recvcount
        TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_allgather(sendbuf, sendcount, &
            sendtype%MPI_VAL, recvbuf, recvcount, recvtype%MPI_VAL, &
            comm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Allgatherv(sendbuf, sendcount, sendtype, recvbuf, &
                              recvcounts, displs, recvtype, comm, ierror)
        TYPE(*), DIMENSION(..), INTENT(IN)  :: sendbuf
        INTEGER,            INTENT(IN)  :: sendcount
        TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
        TYPE(*), DIMENSION(..)          :: recvbuf
        INTEGER,            INTENT(IN)  :: recvcounts(*)
        INTEGER,            INTENT(IN)  :: displs(*)
        TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_allgatherv(sendbuf, sendcount, &
            sendtype%MPI_VAL, recvbuf, recvcounts, displs, recvtype%MPI_VAL, &
            comm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Alltoall(sendbuf, sendcount, sendtype, recvbuf, &
                            recvcount, recvtype, comm, ierror)
        TYPE(*), DIMENSION(..), INTENT(IN)  :: sendbuf
        INTEGER,            INTENT(IN)  :: sendcount
        TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
        TYPE(*), DIMENSION(..)          :: recvbuf
        INTEGER,            INTENT(IN)  :: recvcount
        TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_alltoall(sendbuf, sendcount, &
            sendtype%MPI_VAL, recvbuf, recvcount, recvtype%MPI_VAL, &
            comm%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Alltoallv(sendbuf, sendcounts, sdispls, sendtype, &
                             recvbuf, recvcounts, rdispls, recvtype, comm, ierror)
        TYPE(*), DIMENSION(..), INTENT(IN)  :: sendbuf
        INTEGER,            INTENT(IN)  :: sendcounts(*)
        INTEGER,            INTENT(IN)  :: sdispls(*)
        TYPE(MPI_Datatype), INTENT(IN)  :: sendtype
        TYPE(*), DIMENSION(..)          :: recvbuf
        INTEGER,            INTENT(IN)  :: recvcounts(*)
        INTEGER,            INTENT(IN)  :: rdispls(*)
        TYPE(MPI_Datatype), INTENT(IN)  :: recvtype
        TYPE(MPI_Comm),     INTENT(IN)  :: comm
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_alltoallv(sendbuf, sendcounts, sdispls, &
            sendtype%MPI_VAL, recvbuf, recvcounts, rdispls, recvtype%MPI_VAL, &
            comm%MPI_VAL))
    END SUBROUTINE

    ! ── Datatypes and operations ─────────────────────────────────────────────

    SUBROUTINE MPI_Get_address(location, address, ierror)
        TYPE(*), DIMENSION(..), INTENT(IN)  :: location
        INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(OUT) :: address
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_get_address(location, address))
    END SUBROUTINE

    SUBROUTINE MPI_Type_contiguous(count, oldtype, newtype, ierror)
        INTEGER,            INTENT(IN)  :: count
        TYPE(MPI_Datatype), INTENT(IN)  :: oldtype
        TYPE(MPI_Datatype), INTENT(OUT) :: newtype
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_type_contiguous(count, oldtype%MPI_VAL, &
            newtype%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Type_indexed(count, array_of_blocklengths, &
                                array_of_displacements, oldtype, newtype, ierror)
        INTEGER,            INTENT(IN)  :: count
        INTEGER,            INTENT(IN)  :: array_of_blocklengths(count)
        INTEGER,            INTENT(IN)  :: array_of_displacements(count)
        TYPE(MPI_Datatype), INTENT(IN)  :: oldtype
        TYPE(MPI_Datatype), INTENT(OUT) :: newtype
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_type_indexed(count, array_of_blocklengths, &
            array_of_displacements, oldtype%MPI_VAL, newtype%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Type_create_struct(count, array_of_blocklengths, &
            array_of_displacements, array_of_types, newtype, ierror)
        INTEGER,            INTENT(IN)  :: count
        INTEGER,            INTENT(IN)  :: array_of_blocklengths(count)
        INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(IN) :: array_of_displacements(count)
        TYPE(MPI_Datatype), INTENT(IN)  :: array_of_types(count)
        TYPE(MPI_Datatype), INTENT(OUT) :: newtype
        INTEGER, OPTIONAL,  INTENT(OUT) :: ierror
        INTEGER(c_int) :: types(count)
        types = array_of_types%MPI_VAL
        CALL set_ierror(ierror, lfmpi_type_create_struct(count, &
            array_of_blocklengths, array_of_displacements, types, newtype%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Type_commit(datatype, ierror)
        TYPE(MPI_Datatype), INTENT(INOUT) :: datatype
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_type_commit(datatype%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Type_free(datatype, ierror)
        TYPE(MPI_Datatype), INTENT(INOUT) :: datatype
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_type_free(datatype%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Type_get_extent(datatype, lb, extent, ierror)
        TYPE(MPI_Datatype),             INTENT(IN)  :: datatype
        INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(OUT) :: lb
        INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(OUT) :: extent
        INTEGER, OPTIONAL,              INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_type_get_extent(datatype%MPI_VAL, lb, extent))
    END SUBROUTINE

    SUBROUTINE MPI_Type_create_resized(oldtype, lb, extent, newtype, ierror)
        TYPE(MPI_Datatype),             INTENT(IN)  :: oldtype
        INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(IN)  :: lb
        INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(IN)  :: extent
        TYPE(MPI_Datatype),             INTENT(OUT) :: newtype
        INTEGER, OPTIONAL,              INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_type_create_resized(oldtype%MPI_VAL, lb, &
            extent, newtype%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Op_create(user_fn, commute, op, ierror)
        PROCEDURE(MPI_User_function) :: user_fn
        LOGICAL,      INTENT(IN)  :: commute
        TYPE(MPI_Op), INTENT(OUT) :: op
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        INTEGER(c_int) :: icommute
        icommute = 0
        IF (commute) icommute = 1
        CALL set_ierror(ierror, lfmpi_op_create(c_funloc(user_fn), icommute, &
            op%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Op_free(op, ierror)
        TYPE(MPI_Op), INTENT(INOUT) :: op
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_op_free(op%MPI_VAL))
    END SUBROUTINE

    ! ── Shared memory windows ────────────────────────────────────────────────

    SUBROUTINE MPI_Win_allocate_shared(size, disp_unit, info, comm, baseptr, win, ierror)
        INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(IN) :: size
        INTEGER,        INTENT(IN)  :: disp_unit
        TYPE(MPI_Info), INTENT(IN)  :: info
        TYPE(MPI_Comm), INTENT(IN)  :: comm
        TYPE(c_ptr),    INTENT(OUT) :: baseptr
        TYPE(MPI_Win),  INTENT(OUT) :: win
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_win_allocate_shared(size, disp_unit, &
            info%MPI_VAL, comm%MPI_VAL, baseptr, win%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Win_shared_query(win, rank, size, disp_unit, baseptr, ierror)
        TYPE(MPI_Win), INTENT(IN)  :: win
        INTEGER,       INTENT(IN)  :: rank
        INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(OUT) :: size
        INTEGER,       INTENT(OUT) :: disp_unit
        TYPE(c_ptr),   INTENT(OUT) :: baseptr
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_win_shared_query(win%MPI_VAL, rank, size, &
            disp_unit, baseptr))
    END SUBROUTINE

    SUBROUTINE MPI_Win_fence(assert, win, ierror)
        INTEGER,       INTENT(IN)  :: assert
        TYPE(MPI_Win), INTENT(IN)  :: win
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_win_fence(assert, win%MPI_VAL))
    END SUBROUTINE

    SUBROUTINE MPI_Win_free(win, ierror)
        TYPE(MPI_Win), INTENT(INOUT) :: win
        INTEGER, OPTIONAL, INTENT(OUT) :: ierror
        CALL set_ierror(ierror, lfmpi_win_free(win%MPI_VAL))
    END SUBROUTINE

END MODULE mpi_f08
